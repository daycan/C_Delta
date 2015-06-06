
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
		  		elsif child.name == "ExportTag"
		  			@export_tag = child.text
		  		end
		  	end

		  	@question = Question.new({:question_type => @question_type, :selector => @selector, :sub_selector => @sub_selector, :question_text => @question_text, :question_identifier => @question_identifier, :export_tag => @export_tag})
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
	qualtrics_api_request = "https://survey.qualtrics.com/WRAPI/ControlPanel/api.php?Request=#{request}&User=#{user}&Token=#{token}&Format=#{format}&Version=#{version}&SurveyID=#{qualtrics_survey_identifier}"
	response_xml_doc = HTTParty.get(qualtrics_api_request)
	response  = Nokogiri::XML(response_xml_doc.body)
	
	# This SHOULD (does not currently) get the RIGHT survey associated with the response. 
	@survey = Survey.where({:qualtrics_identifier => qualtrics_survey_identifier }).order("created_at DESC").last

	response.xpath("//Response").each do |r|
		qualtrics_response_id = r.xpath("./ResponseID").text
		if Response.where(qualtrics_response_id: qualtrics_response_id).blank? # Only creates a new response if no response exists with the same response identifier
			qualtrics_response_set = r.xpath("./ResponseSet").text
			name = r.xpath("./Name").text
			email = r.xpath("./EmailAddress").text
			ip_address = r.xpath("./IPAddress").text
			status = r.xpath("./Status").text
			start_date = r.xpath("./StartDate").text
			end_date = r.xpath("./EndDate").text
			finished = r.xpath("./Finished").text

			business_unit_id = 1 # FIX THIS HARD CODING

			@response = Response.new(:business_unit_id => business_unit_id, :qualtrics_response_id => qualtrics_response_id, :qualtrics_response_set => qualtrics_response_set, :name => name, :email => email, :ip_address => ip_address, :status => status, :start_date => status, :end_date => end_date, :finished => finished)
			@response.save

			#cycle through questions and run the logic grabbing the answers from the current Response 'r'
			@survey.questions.each do |q|
				if q.question_type != "DB"

					if q.question_type == "TE"  # Text Entry
						initiate_answer(q)
						@answer.text = r.xpath(".//#{q.export_tag}").text
						@answer.save
					elsif q.question_type == "MC" && q.selector == "SAVR" # Multiple Choice Single Answer
						initiate_answer(q)
						@answer.value = r.xpath(".//#{q.export_tag}").text
						if q.options.where(:option_identifier => @answer.value).exists?
							@option = q.options.where(:option_identifier => @answer.value).first
							@answer.text = @option.description
							@answer.option_id = @option.id
							@answer.save
						end
					elsif q.question_type == "MC" && (q.selector == "MACOL" || q.selector == "MAVR") # Multiple Choice, Multiple Answer
						tag_start = q.export_tag + "_"
						@answer_set = r.xpath(".//*[starts-with(name(), '#{tag_start}')]")
						@answer_set.each do |c|
							initiate_answer(q)
							@answer.value = c.text
							@answer.option_id = c.name.partition('_').last  # I AM HERE. NEED TO SET THIS NEXT
							ap "NEXT"
							ap c
							puts c.text
							puts @answer.option_id
							@answer.save
						end



					end		

				    #t.integer  "response_id"
				    #t.integer  "survey_id"
				    #t.integer  "question_id"
				    #t.string   "value"
				    #t.string   "text"
				    #t.string   "name"
				    #t.integer  "option_id"
				    #t.datetime "created_at",  null: false
				    #t.datetime "updated_at",  null: false
				end

			end

		end

	end

end

def initiate_answer(q)
	@answer = Answer.new
	@answer.response_id = @response.id
	@answer.survey_id = @survey.id
	@answer.question_id = q.id
end
