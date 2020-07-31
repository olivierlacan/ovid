require "./lib/request"
require "./workers/base_worker"

class CaseDataWorker < BaseWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  attr_reader :case_response_data

  def perform(url, cache_key, klass)
    state_klass = Object.const_get(klass)

    puts "Processing #{url} for #{cache_key}"

    metadata = Request.get(url)

    begin
      if metadata.has_key?(:error)
        error = metadata[:error]
        message = "#{error[:code]} - #{error[:message]} for #{url}"
        puts message
        raise message
      end
    rescue => error
      Bugsnag.notify(error) do |report|
        report.severity = "error"

        report.add_tab(:response, {
          url: url,
          metadata: metadata
        })
      end

      return nil
    end

    last_edit = get_last_edit(metadata)

    cached_data = check_cache(state_klass.case_cache_key)

    return cached_data if cached_data

    maximum_record_count = metadata[:standardMaxRecordCount]

    query = {
      where: "1=1",
      returnGeometry: false,
      outFields: "*",
      resultRecordCount: maximum_record_count,
      resultType: "standard"
    }

    record_total = total_records_from_feature(url, query)

    begin
      if record_total == 0
        message = "No results returned for #{url}"
        puts message
        raise message
      end
    rescue => error
      Bugsnag.notify(error) do |report|
        report.severity = "error"

        report.add_tab(:response, {
          url: url,
          last_edit: last_edit,
          record_total: record_total
        })
      end

      # don't re-raise this error and let the job think it completed
      # successfully since we don't want to retry ad infinitum
      return nil
    end

    puts "Total records: #{record_total}"

    @case_response_data = { fields: fields_from_feature(url), features: [] }

    # we need to iterate because the maximum record count sent back per
    # request is lower than the absolute total number of record.
    if record_total > maximum_record_count
      puts "Iterating through #{record_total} records to retrieve all ..."

      threads_needed = record_total / maximum_record_count

      thread_workers = (0..threads_needed).map do |thread_number|
        Thread.new do
          Thread.current.name = "#{thread_number}"

          offset = maximum_record_count * (thread_number)

          begin
            response = Request.get("#{url}/query", params: query.merge(resultOffset: offset))
            last_item_id = response[:features].last[:attributes][:ObjectId]
            puts "Thread #{Thread.current.name}, offset: #{offset}, results: #{response[:features].count}, last item: #{last_item_id}"
            response[:features]
          rescue NoMethodError => error
            Bugsnag.notify(error) do |report|
              report.severity = "error"

              report.add_tab(:response, {
                url: url,
                last_item_id: last_item_id,
                record_total: record_total,
                body: response
              })
            end
          end

          nil
        end
      end

      values = thread_workers.flat_map { _1.value.flatten }
      thread_workers.map(&:join)

      if values.size < record_total
        raise "Failed to retrieve all results: values (#{values.length}), total records: #{record_total}"
      end

      sorted_results = values.sort_by { _1[:attributes][:ObjectId] }

      @case_response_data[:features] = sorted_results
    else
      puts "All records (#{record_total}) can be fetched in a single request!"
    end

    case_keys = state_klass.case_keys

    case_report = generate_case_report(
      @case_response_data[:features],
      initialize_store(case_keys),
      case_keys
    )

    merged_data = {
      edited_at: last_edit,
      fetched_at: Time.now,
      data: case_report,
      show_source: true
    }

    save_in_cache cache_key, merged_data
  rescue => error
    Bugsnag.notify(error) do |report|
      report.severity = "error"

      report.add_tab(:response, {
        values: values.length,
        record_total: record_total
      })
    end

    # let the job die
  end

  def generate_case_report(data, store, case_keys)
    data.each_with_object(store) do |item, store|
      a = item[:attributes]

      case_keys.each do |key, value|
        if value[:count_of_total_records]
          store[key][:value] = data.count
        elsif value[:total]
          store[key][:value] = a[value[:source]]
        elsif value[:positive_value]
          store[key][:positive_value] = value[:positive_value]
          positive_value = a[value[:source]] == value[:positive_value]
          store[key][:value] += 1 if positive_value
        else
          store[key][:value] += a[value[:source]] || 0
        end
      end
    end
  rescue => error
    puts a
    raise error
  end
end
