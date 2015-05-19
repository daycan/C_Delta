class AlterCompanies < ActiveRecord::Migration
  def change
  	add_index("companies", "name_legal")
  	add_index("companies", "name_informal")
  end
end
