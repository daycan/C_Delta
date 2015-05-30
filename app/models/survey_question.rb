class SurveyQuestion < ActiveRecord::Base

  belongs_to :survey
  belongs_to :question

end