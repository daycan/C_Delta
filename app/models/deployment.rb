class Deployment < ActiveRecord::Base

  belongs_to :survey
  belongs_to :business_unit

end