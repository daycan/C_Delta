class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.integer :business_unit_id
      t.integer :survey_id
      t.string :qualtrics_response_id
      t.string :qualtrics_response_set
      t.string :name
      t.string :email
      t.string :ip_address
      t.integer :status
      t.datetime :start_date
      t.datetime :end_date
      t.integer :finished

      t.timestamps null: false
    end
    add_index :responses, :business_unit_id
    add_index :responses, :survey_id
    add_index :responses, :start_date
    add_index :responses, :end_date
    add_index :responses, :finished
  end
end
