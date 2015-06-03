class Question < ActiveRecord::Base
	
	has_many :options
	has_many :survey_questions
	has_many :surveys, :through => :survey_questions
	has_many :answers

end
