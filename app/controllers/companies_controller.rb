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
  	@company = Company.find(params[:id])
  end

  def update
  	@company = Company.find(params[:id])
  	if @company.update_attributes(company_params)
  		redirect_to(:action => 'show', :id => @company.id)
  	else
  		render('edit')
  	end
  end

  def delete
  end

  private

  	def company_params
  		params.require(:company).permit(:name_legal, :name_informal, :email)
  	end

end
