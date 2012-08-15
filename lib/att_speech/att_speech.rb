class ATTSpeech
	include Celluloid
	Celluloid.logger = nil
	
	attr_reader :api_key, :secret_key, :access_token, :refresh_token
	
	##
	# Creates an ATTSpeech object
	#
	# @param [String] api_key
	# @param [String] secret_key
	# @param [String] base_url
	#
	# @return [Object] an instance of ATTSpeech
	def initialize(api_key, secret_key, base_url='https://api.att.com')
		@api_key 		   = api_key
		@secret_key    = secret_key
		@base_url      = base_url
		@grant_type    = 'client_credentials'
		@scope         = 'SPEECH'
		@access_token  = ''
		@refresh_token = ''
		
		create_connection
		get_tokens
		
		self
	end
	
	##
	# Allows you to send a file and return the speech to text result
	# @param [String] file_contents to be processed
	# @param [String] type of file to be processed, may be audio/wav, application/octet-stream or audio/amr
	# @param [String] speech_context to use to evaluate the audio Generic, UVerseEPG, BusinessSearch, Websearch, SMS, Voicemail,  QuestionAndAnswer
	#
	# @return [Hash] the resulting response from the AT&T Speech API
	def speech_to_text(file_contents, type='audio/wav', speech_context='Generic')
		resource = "/rest/1/SpeechToText"
		
		if type == "application/octet-stream"
			type = "audio/amr"
		end
		
		begin
			response = @connection.post resource, file_contents, 
						 			                          :Authorization             => "Bearer #{@access_token}", 
									                          :Content_Transfer_Encoding => 'chunked', 
									                          :X_SpeechContext           => speech_context, 
									                          :Content_Type              => type, 
									                          :Accept                    => 'application/json'
									                          
			process_response(response)
		rescue => e
			raise RuntimeError, e.to_s
		end
	end
	
	private
	
	##
	# Creates the Faraday connection object
	def create_connection
		@connection = Faraday.new(:url => @base_url) do |faraday|
			faraday.headers['Accept'] = 'application/json'
			faraday.adapter           Faraday.default_adapter
		end
	end
	
	##
	# Obtains the session tokens
	def get_tokens
		resource = "/oauth/access_token"
		
		begin
			response = @connection.post resource do |request|
				request.params['client_id']     = @api_key
				request.params['client_secret'] = @secret_key
				request.params['grant_type']    = @grant_type
				request.params['scope']         = @scope
			end
			
			result = process_response(response)
			
			if result[:access_token].nil? || result[:refresh_token].nil?
				raise RuntimeError, "Unable to complete oauth: #{response[:error]}"
			else                
				@access_token  = result[:access_token]
				@refresh_token = result[:refresh_token]
			end
		rescue => e
			raise RuntimeError, e.to_s
		end
	end
	
	##
	# Process the JSON returned into a Hashie::Mash and making it more Ruby friendly
	# 
	# @param [String] reponse json
	#
	# @return [Object] a Hashie::Mash object
	def process_response(response)
		Hashie::Mash.new(underscore_hash(JSON.parse(response.body)))
	end
	
	##
	# Decamelizes the keys in a hash to be more Ruby friendly
	#
	# @param [Hash] hash to be decamelized
	# 
	# @return [Hash] the hash with the keys decamalized
	def underscore_hash(hash)
		hash.inject({}) do |underscored, (key, value)|
			value = underscore_hash(value) if value.is_a?(Hash)
			if value.is_a?(Array)
				value = underscore_hash(value[0]) if value[0].is_a?(Hash)
			end
			underscored[key.underscore] = value
			underscored
		end
	end
end