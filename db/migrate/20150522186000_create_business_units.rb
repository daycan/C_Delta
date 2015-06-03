class CreateBusinessUnits < ActiveRecord::Migration
  def change
    create_table :business_units do |t|
    	t.integer "organization_id"
        t.string "name", :limit => 100
        t.string "industry", :limit => 100
        t.timestamps null: false
    end

    add_index("business_units", "name")
  	add_index("business_units", "industry")
  	add_index("business_units", "organization_id")


  end
end


