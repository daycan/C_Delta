class BusinessUnitsController < ApplicationController
  def index
    @business_units = BusinessUnit.all
  end

  def show
    @organization = Organization.find(params[:organization_id])
    @business_unit = BusinessUnit.find(params[:id])
  end

  def new
    @business_unit = BusinessUnit.new({:name => "Default", :organization_id => params[:organization_id]})
  end

  def create
    @business_unit = BusinessUnit.new(business_unit_params)

    respond_to do |format|
      if @business_unit.save
        format.html { redirect_to @business_unit, notice: 'Business Unit was successfully created.' }
        format.json { render :show, status: :created, location: @business_unit }
      else
        format.html { render :new }
        format.json { render json: @business_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @business_unit = BusinessUnit.find(params[:id])
  end

  def update
    respond_to do |format|
      if @business_unit.update(business_unit_params)
        format.html { redirect_to @business_unit, notice: 'Business Unit was successfully updated.' }
        format.json { render :show, status: :ok, location: @business_unit }
      else
        format.html { render :edit }
        format.json { render json: @business_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
    @business_unit = BusinessUnit.find(params[:id])
  end


  def destroy
    @organization = Organization.find(params[:organization_id])
    @business_unit = BusinessUnit.find(params[:id]).destroy
    flash[:notice] = "Business Unit destroyed successfully."
    redirect_to @organization
  end

  private

    def business_unit_params
      params.require(:business_unit).permit(:organization_id, :name, :industry)
    end

end
