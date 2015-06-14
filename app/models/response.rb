class Response < ActiveRecord::Base

	belongs_to :business_unit
	belongs_to :survey
	has_many :answers

end
