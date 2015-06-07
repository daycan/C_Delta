class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string :survey_name
      t.integer :is_active
      t.string :owner_id
      t.string :qualtrics_identifier

      t.timestamps null: false
    end

    create_table :deployments, id: false do |t|
      t.belongs_to :survey, index: true
      t.belongs_to :business_unit, index: true
    end

    add_column :business_units, :survey_id, :integer

    add_index :surveys, :survey_name
    add_index :surveys, :is_active
    add_index :surveys, :owner_id
    add_index :surveys, :qualtrics_identifier

    add_index :business_units, :survey_id
  end
end

