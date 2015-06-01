class SurveysController < ApplicationController
  def index
  	@survey = Survey.all
  end

  def show
  end

  def delete
  end

  def destroy
  end
end
