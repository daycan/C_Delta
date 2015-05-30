class BusinessUnit < ActiveRecord::Base

  belongs_to :organization
  has_and_belongs_to_many :surveys
  has_many :responses

end
