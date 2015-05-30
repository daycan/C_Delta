class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :question_type
      t.string :selector
      t.string :sub_selector
      t.text :question_text
      t.string :question_identifier

      t.timestamps null: false
    end

    create_table :survey_questions do |t|
      t.belongs_to :question, index: true
      t.belongs_to :survey, index: true

      t.timestamps null: false
    end

    add_index :questions, :question_identifier
  end

end
