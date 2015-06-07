class BusinessUnit < ActiveRecord::Base

  belongs_to :organization
  has_many :responses

  has_many :deployments
  has_many :surveys, :through => :deployments

end
