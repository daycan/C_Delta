class AddCompanyIdToBusinessUnit < ActiveRecord::Migration
  def change
  	add_column :business_units, :company_id, :integer
  	add_index :business_units, :company_id
  end
end
