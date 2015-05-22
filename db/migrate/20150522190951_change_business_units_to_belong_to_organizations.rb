class ChangeBusinessUnitsToBelongToOrganizations < ActiveRecord::Migration
  def change
  	add_column :business_units, :organization_id, :integer
  	add_index :business_units, :organization_id
  end
end
