class CompaniesController < ApplicationController
  
  layout false

  def index
  	@companies = Company.order("name_legal ASC")
  end

  def show
  	@company = Company.find(params[:id])
  end

  def new
  end

  def edit
  end

  def delete
  end
end
