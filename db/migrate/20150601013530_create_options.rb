class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
    	t.integer :question_id
    	t.string :description
    	t.integer :option_identifier
    	t.integer :recode
    	t.integer :has_text

      t.timestamps null: false
    end
    add_index :options, :description
    add_index :options, :option_identifier
    add_index :options, :recode
    add_index :options, :has_text
    add_index :options, :question_id
  end
end
