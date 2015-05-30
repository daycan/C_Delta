class Survey < ActiveRecord::Base

	has_and_belongs_to_many :business_units
	has_many :survey_questions
	has_many :questions, :through => :survey_questions

end
