
task :add_survey => :environment do

	desc "add a survey to the database"

	# Code below is ROUGH, it has AT LEAST the following problems
	# Survey token and ID must currently be hard coded in the URL below to import a new survey
	# Survey currently is not properly attached to Business Units (goes directly to business unit id instead of using the many-to-many relationship style)

	survey_id = "SV_bClgHUmIroUjqdv"
	request = "getSurvey"
	user = "daycan@ideo.com"
	token = "CrgjxL2m2tp54NQqDStoUFBtVEUZgw77sTZFKohY"
	version = "2.4"

	qualtrics_api_request = "https://survey.qualtrics.com/WRAPI/ControlPanel/api.php?Request=#{request}&User=#{user}&Token=#{token}&Version=#{version}&SurveyID=#{survey_id}"
	
	survey_xml_doc = HTTParty.get(qualtrics_api_request) # grabs the xml export of the survey structure from qualtrics
	survey = Nokogiri::XML(survey_xml_doc.body) # turns the xml export of the survey into a parsable format (can us .xpath("//tag")) etc.

	# FIX: business_unit_id is being hard-coded here
	business_unit_id = 1
	survey_name = survey.xpath("//SurveyName//text()")
	is_active = survey.xpath("//isActive//text()")
	owner_id = survey.xpath("//OwnerID//text()")

	
	@survey = Survey.new({:business_unit_id => business_unit_id, :survey_name => survey_name, :is_active => is_active, :owner_id => owner_id})
	@survey.save

	survey.xpath("//Question").each do |q|
		ap puts q
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
		  		elsif child.name = "QuestionText"
		  			@question_text = child.text
		  		elsif child.name = "SubSelector"
		  			@sub_selector = child.text
		  		end
		  	end

		  	@question = Question.new({:question_type => @question_type, :selector => @selector, :sub_selector => @sub_selector, :question_text => @question_text, :question_identifier => @question_identifier})
		  	@question.save
		  	@survey.questions << @question

		end

				#create the options
			# if question exists, check that the main options have not changed
				#if the options have changed, add the new options

	end
end




task :get_qualtrics_data => :environment do
	
	response_xml_doc = HTTParty.get('https://survey.qualtrics.com/WRAPI/ControlPanel/api.php?Request=getLegacyResponseData&User=daycan@ideo.com&Token=CrgjxL2m2tp54NQqDStoUFBtVEUZgw77sTZFKohY&Format=XML&Version=2.4&SurveyID=SV_bClgHUmIroUjqdv')
	response  = Nokogiri::XML(response_xml_doc.body)
	
	# This SHOULD (does not currently) get the RIGHT survey associated with the response. 
	@survey = Survey.order("created_at").last


	puts ap response

	


end