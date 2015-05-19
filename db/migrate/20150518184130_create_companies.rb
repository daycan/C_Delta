class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string "name_legal", :limit => 100
      t.string "name_informal", :limit => 50
      t.string "password", :limit => 40
      t.timestamps null: false
    end
  end
end
