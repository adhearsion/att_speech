# encoding: utf-8

require 'core_ext/att_multipart'

class ATTSpeech
  include Celluloid
  Celluloid.logger = nil

  attr_reader :api_key, :secret_key, :access_token, :refresh_token, :base_url, :ssl_verify

  ##
  # Creates an ATTSpeech object
  #
  # @overload initialize(args)
  #   @param [Hash] args the options to intantiate with
  #   @option args [String] :api_key the AT&T Speech API Key
  #   @option args [String] :secret_key the AT&T Speech API Secret Key
  #   @option args [String] :base_url the url for the AT&T Speech API, default is 'https://api.att.com'
  #   @option args [Boolean] :ssl_verify determines if the peer Cert is verified for SSL, default is true
  # @overload initialize(api_key, secret_key, base_url='https://api.att.com')
  #   @param [String] api_key the AT&T Speech API Key
  #   @param [String] secret_key the AT&T Speech API Secret Key
  #   @param [String] base_url the url for the AT&T Speech API, default is 'https://api.att.com'
  #   @param [Boolean] ssl_verify determines if the peer Cert is verified for SSL, default is true
  #
  # @return [Object] an instance of ATTSpeech
  def initialize(*args)
    raise ArgumentError, "Requires at least the api_key and secret_key when instatiating" if args.size == 0

    base_url   = 'https://api.att.com'

    if args.size == 1 && args[0].instance_of?(Hash)
      args = args.shift
      @api_key    = args[:api_key]
      @secret_key = args[:secret_key]
      @base_url   = args[:base_url]   || base_url
      set_ssl_verify args[:ssl_verify]
    else
      @api_key    = args.shift
      @secret_key = args.shift
      @base_url   = args.shift || base_url
      set_ssl_verify args.shift
    end

    @grant_type    = 'client_credentials'
    @access_token  = ''
    @refresh_token = ''

    create_connection 'application/json'

    get_tokens

    Actor.current
  end

  ##
  # Allows you to send a file and return the speech to text result
  # @param [String] file_contents to be processed
  # @param [String] type of file to be processed, may be audio/wav, application/octet-stream or audio/amr
  # @param [String] speech_context to use to evaluate the audio BusinessSearch, Gaming, Generic, QuestionAndAnswer, SMS, SocialMedia, TV, VoiceMail, WebSearch
  #
  # @return [Hash] the resulting response from the AT&T Speech API
  def speech_to_text(file_contents, type='audio/wav', speech_context='Generic', options = {})
    resource = "/speech/v3/speechToText"

    # FIXME: Is this necessary?
    if type == "application/octet-stream"
      type = "audio/amr"
    end

    headers = {
      :Authorization             => "Bearer #{@access_token}",
      :Content_Transfer_Encoding => 'chunked',
      :Accept                    => 'application/json'
    }

    if options.has_key?(:grammar)
      # Assume this is a Speech-To-Text-Custom query
      resource << 'Custom'
      options[:grammar] = "<?xml version=\"1.0\"?>\n#{options[:grammar]}"
      body = {
        'x-grammar' => Faraday::UploadIO.new(StringIO.new(options[:grammar]), 'application/srgs+xml'),
        'x-voice'   => Faraday::UploadIO.new(StringIO.new(file_contents), type)
      }
    else
      headers[:X_SpeechContext] = speech_context
      body = file_contents
    end

    response = @connection.post resource, body, headers

    result = process_response(response)
    result
  end


  ##
  # Allows you to send a string or plain text file and return the text to speech result
  # @param [String] text_data string or file_contents to be processed
  # @param [String] options hash with options which will be send to AT&T Speech API
  #
  # @return [String] the bytes of the resulting response from the AT&T Speech API
  def text_to_speech(text_data, options = {})
    resource = '/speech/v3/textToSpeech'
    params = {
      :Authorization => "Bearer #{@access_token}",
      :Content_Type  => 'text/plain',
      :Accept        => 'audio/x-wav'
    }.merge(options)

    begin
      response = @connection.post( resource, text_data, params )
      response.body
    rescue => e
      raise RuntimeError, e.to_s
    end
  end


  private

  ##
  # Creates the Faraday connection object
  def create_connection(accept_type='application/json')
    @connection = Faraday.new(:url => @base_url, :ssl => { :verify => @ssl_verify }) do |faraday|
      faraday.headers['Accept'] = accept_type
      faraday.request :att_multipart
      faraday.adapter Faraday.default_adapter
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
        request.params['scope']         = 'SPEECH,STTC,TTS'
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
  # Sets the ssl_verify option
  #
  # @param [Boolean] ssl_verify the variable to set
  def set_ssl_verify(ssl_verify)
    if ssl_verify == false
      @ssl_verify =  false
    else
      @ssl_verify = true
    end
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
