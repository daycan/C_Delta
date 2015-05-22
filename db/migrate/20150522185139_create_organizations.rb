class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
    	t.string "name_legal", :limit => 100
    	t.string "name_informal", :limit => 50
    	t.string "industry", :limit => 100
        t.timestamps null: false
    end
    add_index("organizations", "name_legal")
  	add_index("organizations", "name_informal")
  	add_index("organizations", "industry")
  end
end
