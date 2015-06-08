
def org_legal_name
	"Intercorp Peru Ltd."
end

def	qualtrics_survey_identifier 
	"SV_9GCQw97N32SZHhj" 
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

def business_unit_question
	"QID132" # Qualtrics question identifier for question containing current Business Units
end

def business_unit_question_export_tag
	"Q3"
end


task :import_qualtrics_survey => :environment do

	desc "add a survey to the database"

	# Code below is ROUGH, it has AT LEAST the following problems
	# Survey token and ID must currently be hard coded in the URL below to import a new survey
	# Survey currently is not properly attached to Business Units (goes directly to business unit id instead of using the many-to-many relationship style)

	request = "getSurvey"

	qualtrics_api_request = "https://survey.qualtrics.com/WRAPI/ControlPanel/api.php?Request=#{request}&User=#{user}&Token=#{token}&Version=#{version}&SurveyID=#{qualtrics_survey_identifier}"
	
	survey_xml_doc = HTTParty.get(qualtrics_api_request) # grabs the xml export of the survey structure from qualtrics
	survey = Nokogiri::XML(survey_xml_doc.body) # turns the xml export of the survey into a parsable format (can us .xpath("//tag")) etc.

	survey_name = survey.xpath("//SurveyName//text()")
	is_active = survey.xpath("//isActive").text
	owner_id = survey.xpath("//OwnerID//text()")

	
	@survey = Survey.new({:survey_name => survey_name, :is_active => is_active, :owner_id => owner_id, :qualtrics_identifier => qualtrics_survey_identifier})
	@survey.save

	
	# Cycle through each business unit choice for the survey and add associate this survey with each of those business units
	query = "//Question[@QuestionID='#{business_unit_question}']"
	survey.xpath(query).first.xpath(".//Choice").each do |node|
		bu_name = node.at_xpath(".//Description").text
		if bu_name != "(Please choose one)" && bu_name != "I work with many companies at once"
			org = Organization.where(:name_legal => org_legal_name).first
			bu = org.business_units.where(:name => bu_name).first
			bu.surveys << @survey
			bu.save
		end
	end

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


task :import_qualtrics_responses => :environment do

	request = "getLegacyResponseData"
	qualtrics_api_request = "https://survey.qualtrics.com/WRAPI/ControlPanel/api.php?Request=#{request}&User=#{user}&Token=#{token}&Format=#{format}&Version=#{version}&SurveyID=#{qualtrics_survey_identifier}"
	response_xml_doc = HTTParty.get(qualtrics_api_request)
	response  = Nokogiri::XML(response_xml_doc.body)
	
	# This SHOULD (does not currently) get the RIGHT survey associated with the response. 
	@survey = Survey.where({:qualtrics_identifier => qualtrics_survey_identifier }).order("created_at DESC").last

	@business_units = Organization.where(:name_legal => org_legal_name).first.business_units
	@business_unit_options = @survey.questions.where(:question_identifier => business_unit_question).first.options

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

			business_unit_answer_choice = r.xpath(".//#{business_unit_question_export_tag}").text
			

			business_unit_name = @business_unit_options.where(:option_identifier => business_unit_answer_choice).first.description
			puts "FIGURING OUT THE BUSINESS UNIT"
			ap business_unit_name
			ap business_unit_answer_choice
			business_unit_id = @business_units.where(:name => business_unit_name).first.id

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
							@answer.name = q.export_tag
							@answer.option_id = @option.id
							@answer.save
						end

					elsif q.question_type == "Slider" # For Questions with Slider bar
						get_answer_set(q, r) #NEED TO FIX: NOT ALL HAVE THE "_", BUT EXCLUDING BLANK GETS NUMBER W 10X TOO e.g. looking for Q6 will get Q60
						@answer.value = @answer_set.first.text
						@answer.name = @answer_set.first.name
						@answer.save

					elsif (q.question_type == "MC" && (q.selector == "MACOL" || q.selector == "MAVR")) || q.question_type == "Matrix" # Multiple Choice, Multiple Answer (with and without text entry), Matrix type answer (multiple columns and rows)
						get_answer_set(q, r)
						@answer_set.each do |c|
							initiate_answer(q)
							@answer.value = c.text
							@answer.name = c.name 
							unless c.name.split('_')[1].include? 'x' # 'Piped' answers include this 'x' in this case, the survey template does not give any hint to the answers and so the options are not created. Need to design a better way to deal with this here. 
								@answer.option_id = Option.where(:question_id => q.id, :option_identifier => c.name.split('_')[1]).last.id  
							end
							@answer.save
						end

					elsif q.question_type == "PGR" # Drag and Drop (and possibly other types)			
						get_answer_set(q, r)
						@answer_set.each do |c|
							if c.name.end_with?("Group")
								initiate_answer(q)
								@answer.value = c.text
								@answer.name = c.name.split('_')[0] + '_' + c.name.split('_')[1]
								@answer.option_id = Option.where(:question_id => q.id, :option_identifier => c.name.split('_')[1]).last.id  
								@answer.group = c.text
								@answer.save
							elsif c.name.end_with?("Rank")
								@answer_name = c.name.split('_')[0] + '_' + c.name.split('_')[1] # Strip 'Rank' out of the tag name
								@answer = Answer.where(:response_id => @response.id, :name => @answer_name).first
								@answer.rank = c.text
								@answer.save
							end
						end
					end		
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

def get_answer_set(q, r)
	tag_start = q.export_tag + "_"
	@answer_set = r.xpath(".//*[starts-with(name(), '#{tag_start}')]")
end
