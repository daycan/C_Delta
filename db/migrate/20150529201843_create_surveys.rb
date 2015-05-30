class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.integer :business_unit_id
      t.string :survey_name
      t.integer :is_active
      t.string :owner_id

      t.timestamps null: false
    end

    create_table :surveys_business_units, id: false do |t|
      t.belongs_to :survey, index: true
      t.belongs_to :business_unit, index: true
    end

    add_index :surveys, :survey_name
    add_index :surveys, :is_active
    add_index :surveys, :owner_id
  end
end

