Sequel.migration do
  up do
    create_table :seeds do
      primary_key  :id
      String       :term, unique: true, null: false
      DateTime     :created_at,         null: false
      DateTime     :updated_at
      DateTime     :last_planted
    end
  end

  down do
    drop_table(:seeds)
  end
end
