
task :add_survey => :environment do

	desc "add a survey to the database"

	# Code below is ROUGH, it has AT LEAST the following problems
	# Survey token and ID must currently be hard coded in the URL below to import a new survey
	# Survey currently has no way to be attached to Business Units

	survey_id = "SV_bClgHUmIroUjqdv"
	request = "getSurvey"
	user = "daycan@ideo.com"
	token = "CrgjxL2m2tp54NQqDStoUFBtVEUZgw77sTZFKohY"
	version = "2.4"

	qualtrics_api_request = "https://survey.qualtrics.com/WRAPI/ControlPanel/api.php?Request=#{request}&User=#{user}&Token=#{token}&Version=#{version}&SurveyID=#{survey_id}"
	
	survey_xml_doc = HTTParty.get(qualtrics_api_request)

	#survey_xml_doc = HTTParty.get('https://survey.qualtrics.com/WRAPI/ControlPanel/api.php?Request=getSurvey&User=daycan@ideo.com&Token=CrgjxL2m2tp54NQqDStoUFBtVEUZgw77sTZFKohY&Version=2.4&SurveyID=SV_bClgHUmIroUjqdv')

	survey = Nokogiri::XML(survey_xml_doc.body)

	puts ap survey

	# FIX: business_unit_id is being hard-coded here
	business_unit_id = 1
	survey_name = survey.xpath("//SurveyName//text()")
	is_active = survey.xpath("//isActive//text()")
	owner_id = survey.xpath("//OwnerID//text()")

	
	@survey = Survey.new({:business_unit_id => business_unit_id, :survey_name => survey_name, :is_active => is_active, :owner_id => owner_id})
	@survey.save

end



task :get_qualtrics_data do
	


	response_xml_doc = HTTParty.get('https://survey.qualtrics.com/WRAPI/ControlPanel/api.php?Request=getLegacyResponseData&User=daycan@ideo.com&Token=CrgjxL2m2tp54NQqDStoUFBtVEUZgw77sTZFKohY&Format=XML&Version=2.4&SurveyID=SV_bClgHUmIroUjqdv')
	response  = Nokogiri::XML(response_xml_doc.body)
	
	
	puts ap response

	


end