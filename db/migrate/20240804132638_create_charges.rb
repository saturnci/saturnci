class CreateCharges < ActiveRecord::Migration[7.1]
  def change
    create_table :charges, id: :uuid do |t|
      t.references :job, null: false, foreign_key: true, type: :uuid
      t.decimal :rate, null: false
      t.decimal :job_duration, null: false

      t.timestamps
    end

    add_index :charges, :job_id, unique: true, name: 'unique_index_on_charges_job_id'
  end
end
