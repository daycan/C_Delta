class Response < ActiveRecord::Base

	belongs_to :business_unit
	has_many :answers

end
