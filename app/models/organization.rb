class Organization < ActiveRecord::Base

	has_many :business_units
	accepts_nested_attributes_for :business_units


end
