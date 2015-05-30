class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :type
      t.string :selector
      t.string :sub_selector
      t.text :question_text
      t.string :question_identifier

      t.timestamps null: false
    end

    create_table :survey_questions do |t|
      t.belongs_to :questions, index: true
      t.belongs_to :surveys, index: true

      t.timestamps null: false
    end

    add_index :questions, :question_identifier
  end
  
end
