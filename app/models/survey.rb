class Survey < ActiveRecord::Base

	has_many :deployments
	has_many :business_units, :through => :deployments
	has_many :responses
	
	has_many :survey_questions
	has_many :questions, :through => :survey_questions
	
	has_many :answers

end
