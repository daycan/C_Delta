class Organization < ActiveRecord::Base

	has_many :business_units
	accepts_nested_attributes_for :business_units


	validates_uniqueness_of :name_legal


end
