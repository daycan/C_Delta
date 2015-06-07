class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :response_id
      t.integer :survey_id
      t.integer :question_id
      t.integer :value
      t.string :text
      t.string :name
      t.integer :option_id
      t.integer :group
      t.integer :rank


      t.timestamps null: false
    end
    add_index :answers, :response_id
    add_index :answers, :survey_id
    add_index :answers, :question_id
    add_index :answers, :option_id
    add_index :answers, :value
    add_index :answers, :text
    add_index :answers, :name
    add_index :answers, :group
    add_index :answers, :rank

  end
end
