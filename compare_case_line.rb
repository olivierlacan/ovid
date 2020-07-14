# frozen_string_literal: true

require "csv"
require "date"
require "time"
require "digest"
require "pathname"
require 'csv-diff'

unless ARGV[0] && ARGV[1]
  abort <<~STRING
    Pass two filenames to compare their fingerprints.
    Example:
      ruby compare_case_line.rb case_line_data_2020-03-30.csv case_line_data_2020-05-20_03.csv
  STRING
end

diff = CSVDiff.new(ARGV[0],ARGV[1], key_fields: ['MD5fingerprint'])
puts diff.summary

# matches = []

# first = CSV.read(ARGV[0], headers: true, header_converters: :symbol)
# CSV.foreach(ARGV[1], headers: true, header_converters: :symbol) do |row|
#   first.find do |first_row|
#     binding.irb
#     if first_row[:md5fingerprint] == row[:md5fingerprint]
#       print ""
#       matches << row[:md5fingerprint]
#     else
#       print "x"
#     end
#   end
# end

# $ ruby compare_case_line.rb 2020-03-30 2020-04-10_10
# {"Delete"=>37, "Add"=>3275, "Update"=>596, "Warning"=>14322}
# $ ruby compare_case_line.rb 2020-03-30 2020-05-20
# {"Delete"=>45, "Add"=>5917, "Update"=>588, "Warning"=>41806}
# $ ruby compare_case_line.rb 2020-03-30 2020-06-29
# {"Delete"=>47, "Add"=>8849, "Update"=>586, "Warning"=>138273}
