
def	qualtrics_survey_identifier 
	"SV_bClgHUmIroUjqdv" 
end

def user 
	"daycan@ideo.com"
end
	
def token 
	"CrgjxL2m2tp54NQqDStoUFBtVEUZgw77sTZFKohY"
end

def version 
	"2.4"
end

def format
	"XML"
end

task :add_survey => :environment do

	desc "add a survey to the database"

	# Code below is ROUGH, it has AT LEAST the following problems
	# Survey token and ID must currently be hard coded in the URL below to import a new survey
	# Survey currently is not properly attached to Business Units (goes directly to business unit id instead of using the many-to-many relationship style)

	request = "getSurvey"

	qualtrics_api_request = "https://survey.qualtrics.com/WRAPI/ControlPanel/api.php?Request=#{request}&User=#{user}&Token=#{token}&Version=#{version}&SurveyID=#{qualtrics_survey_identifier}"
	
	survey_xml_doc = HTTParty.get(qualtrics_api_request) # grabs the xml export of the survey structure from qualtrics
	survey = Nokogiri::XML(survey_xml_doc.body) # turns the xml export of the survey into a parsable format (can us .xpath("//tag")) etc.

	business_unit_id = nil # FIX: business_unit_id is being hard-coded here
	survey_name = survey.xpath("//SurveyName//text()")
	is_active = survey.xpath("//isActive").text
	owner_id = survey.xpath("//OwnerID//text()")

	
	@survey = Survey.new({:business_unit_id => business_unit_id, :survey_name => survey_name, :is_active => is_active, :owner_id => owner_id, :qualtrics_identifier => qualtrics_survey_identifier})
	@survey.save

	survey.xpath("//Question").each do |q|
		@question_identifier = q.first[1] # returns the question number in format [QID71]
		# see if question already exists in the database
		if @question = Question.where(:question_identifier => @question_identifier).first
			@question.surveys << @survey # attaches the existing question to the new survey
		else # if question does not exist create it
		  	q.children.each do |child|
		  		if child.name == "Selector" 
		  			@selector = child.text
		  		elsif child.name == "Type"
		  			@question_type = child.text
		  		elsif child.name == "QuestionText"
		  			@question_text = child.text
		  		elsif child.name == "SubSelector"
		  			@sub_selector = child.text
		  		end
		  	end

		  	@question = Question.new({:question_type => @question_type, :selector => @selector, :sub_selector => @sub_selector, :question_text => @question_text, :question_identifier => @question_identifier})
		  	@question.save
		  	@survey.questions << @question

			# CHECK AND SET OPTIONS
			# STILL NEED: if question exists, check that the main options have not changed
			# STILL NEED: Then, if the options have changed, add the new options
		  	q.xpath(".//Choice").each do |c|
		  		option_identifier = c.xpath("@ID").first.value
		  		recode = c.xpath("@Recode").first.value
		  		c.xpath("@TextEntry").each do
		  			@has_text = 1
		  			puts "FOUND ONE"
	  			end		  			

		  		c.children.each do |child|
		  			if child.name == "Description"
		  				@description = child.text
		  			end
		  		end

	  			@option = Option.new({:description => @description, :option_identifier => option_identifier, :recode => recode, :has_text => @has_text })	
	  			@option.save
	  			@question.options << @option

	  			@has_text = 0 # Set back to default of 0 to re-run check
	  	
		  	end
		end


	end
end


task :get_qualtrics_responses => :environment do

	request = "getLegacyResponseData"
	qualtrics_api_request = 'https://survey.qualtrics.com/WRAPI/ControlPanel/api.php?Request=#{request}&User=#{user}&Token=#{token}&Format=#{format}&Version=#{version}&SurveyID=#{qualtrics_survey_identifier}'
	response_xml_doc = HTTParty.get(qualtrics_api_request)
	response  = Nokogiri::XML(response_xml_doc.body)
	
	# This SHOULD (does not currently) get the RIGHT survey associated with the response. 
	@survey = Survey.where({:qualtrics_identifier => qualtrics_survey_identifier }).order("created_at DESC").last


	response.xpath("//Response").each do |r|
		response_identifier = r.xpath("./ResponseID").text
		business_unit_id = 1 # FIX THIS HARD CODING



	end




end



