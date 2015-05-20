class CompaniesController < ApplicationController
  
  layout false

  def index
  	@companies = Company.order("name_legal ASC")
  end

  def show
  end

  def new
  end

  def edit
  end

  def delete
  end
end
