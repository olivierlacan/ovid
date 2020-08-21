Sequel.migration do
  change do
    create_table(:temporary_case_line_data) do
      primary_key :object_id
      String :age, null: true
      String :age_group, null: true
      String :case_, null: true
      String :contact, null: true
      String :county, null: true
      String :died, null: true
      String :edvisit, null: true
      String :gender, null: true
      String :hospitalized, null: true
      String :jurisdiction, null: true
      String :origin, null: true
      String :travel_related, null: true
      Time :eventdate, null: true
      Time :chartdate, null: true
      Time :case1, null: true
    end
  end
end
