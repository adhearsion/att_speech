require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "AttSpeech" do
  FakeWeb.allow_net_connect = false

  FakeWeb.register_uri(:post,
                       "https://api.att.com/oauth/access_token?client_id=1234&client_secret=abcd&grant_type=client_credentials&scope=SPEECH",
                       :status => ['200', 'OK'],
                       :body   => '{"access_token":"5678","refresh_token":"wxyz"}')

  FakeWeb.register_uri(:post,
                       "http://foobar.com/oauth/access_token?client_id=1234&client_secret=abcd&grant_type=client_credentials&scope=SPEECH",
                       :status => ['200', 'OK'],
                       :body   => '{"access_token":"5678","refresh_token":"wxyz"}')

  FakeWeb.register_uri(:post,
                       "https://api.att.com/speech/v3/speechToText",
                       :status => ['200', 'OK'],
                       :body   => "{\"Recognition\":{\"ResponseId\":\"2b0bdcf4301f5c4aba57e2765b59bcbe\",\"NBest\":[{\"WordScores\":[1,1],\"Confidence\":1,\"Grade\":\"accept\",\"ResultText\":\"Boston celtics.\",\"Words\":[\"Boston\",\"celtics.\"],\"LanguageId\":\"en-us\",\"Hypothesis\":\"Boston celtics.\"}]}}")

  FakeWeb.register_uri(:post,
                       "https://api.att.com/speech/v3/textToSpeech",
                       :status => ['200', 'OK'],
                       :body   => nil )

  let(:att_speech)      { att_speech = ATTSpeech.new('1234', 'abcd', 'SPEECH') }
  let(:att_speech_hash) { att_speech = ATTSpeech.new({ :api_key    => '1234',
                                                       :secret_key => 'abcd',
                                                       :scope      => 'SPEECH' })}


  describe 'initializing' do
    it "should raise an error of no parameters passed when creating object" do
      begin
        ATTSpeech.new
      rescue => e
        e.to_s.should eql "Requires at least the api_key, secret_key, and scope when instatiating"
      end
    end

    it "shoud raise an error of wrong scope when creating object without scope" do
      begin
        ATTSpeech.new('1234', 'abcd')
      rescue => e
        e.to_s.should eql "scope must be either 'SPEECH' or 'TTS'"
      end
    end

    it "shoud raise an error of wrong scope when creating object with misspelled scope" do
      begin
        ATTSpeech.new('1234', 'abcd', 'misspelled scope')
      rescue => e
        e.to_s.should eql "scope must be either 'SPEECH' or 'TTS'"
      end
    end

    it "should create an ATTSpeech object" do
      att_speech.class.should eql ATTSpeech
      att_speech_hash.class.should eql ATTSpeech
    end

    it 'should set the url to something different' do
      as = ATTSpeech.new('1234', 'abcd', 'SPEECH', 'http://foobar.com', false)
      as.base_url.should   == 'http://foobar.com'
      as.ssl_verify.should == false

      as = ATTSpeech.new({ :api_key    => '1234',
                           :secret_key => 'abcd',
                           :scope      => 'SPEECH',
                           :base_url   => 'http://foobar.com',
                           :ssl_verify => false })
      as.base_url.should   == 'http://foobar.com'
      as.ssl_verify.should == false
    end

    it "should set the access_token and refresh_token" do
      att_speech.access_token.should  eql '5678'
      att_speech.refresh_token.should eql 'wxyz'
      att_speech.base_url.should      == 'https://api.att.com'
      att_speech.ssl_verify.should    == true

      att_speech_hash.access_token.should  eql '5678'
      att_speech_hash.refresh_token.should eql 'wxyz'
      att_speech_hash.base_url.should      == 'https://api.att.com'
      att_speech_hash.ssl_verify.should    == true
    end
  end

  describe 'blocking call' do
    it "should return a Hashie::Mash object when processing an audio file" do
      result = att_speech.speech_to_text 'spec/spec_helper.rb'
      result.instance_of?(Hashie::Mash).should eql true

      result = att_speech_hash.speech_to_text 'spec/spec_helper.rb'
      result.instance_of?(Hashie::Mash).should eql true
    end

    it "should attempt to process an audio file" do
      result = att_speech.speech_to_text 'spec/spec_helper.rb'
      result[:recognition][:response_id].should eql '2b0bdcf4301f5c4aba57e2765b59bcbe'
      result[:recognition][:n_best][:confidence].should eql 1

      result = att_speech_hash.speech_to_text 'spec/spec_helper.rb'
      result[:recognition][:response_id].should eql '2b0bdcf4301f5c4aba57e2765b59bcbe'
      result[:recognition][:n_best][:confidence].should eql 1
    end
  end

  describe 'non-blocking call' do
    it "should return a Celluloid::Future object when processing an audio file" do
      future = att_speech.future(:speech_to_text, 'spec/spec_helper.rb')
      future.instance_of?(Celluloid::Future).should eql true

      future = att_speech_hash.future(:speech_to_text, 'spec/spec_helper.rb')
      future.instance_of?(Celluloid::Future).should eql true
    end

    it "should allow us to use a future to process an audio file" do
      future = att_speech.future(:speech_to_text, 'spec/spec_helper.rb')
      future.value[:recognition][:response_id].should eql '2b0bdcf4301f5c4aba57e2765b59bcbe'
      future.value[:recognition][:n_best][:confidence].should eql 1

      future = att_speech_hash.future(:speech_to_text, 'spec/spec_helper.rb')
      future.value[:recognition][:response_id].should eql '2b0bdcf4301f5c4aba57e2765b59bcbe'
      future.value[:recognition][:n_best][:confidence].should eql 1
    end
  end

  describe 'non-blocking call with a block' do
    it "should allow us to use a future to process an audio file and pass a block" do
      result = nil
      att_speech.speech_to_text!('spec/spec_helper.rb') { |transcription| result = transcription }
      sleep 0.5
      result[:recognition][:response_id].should eql '2b0bdcf4301f5c4aba57e2765b59bcbe'
      result[:recognition][:n_best][:confidence].should eql 1

      result = nil
      att_speech_hash.speech_to_text!('spec/spec_helper.rb') { |transcription| result = transcription }
      sleep 0.5
      result[:recognition][:response_id].should eql '2b0bdcf4301f5c4aba57e2765b59bcbe'
      result[:recognition][:n_best][:confidence].should eql 1
    end
  end

  context 'text to speech' do
    it 'should request a TTS transaction' do
      text = 'Hello brown cow'
      result = att_speech.text_to_speech text
      FakeWeb.last_request.body.should eql text
      FakeWeb.last_request.get_fields('authorization').should eql ["Bearer 5678"]
      FakeWeb.last_request.get_fields('content-type').should eql ["text/plain"]
      FakeWeb.last_request.get_fields('accept').should eql ["audio/x-wav"]
    end

    it 'should request a TTS transaction with additional options' do
      text = 'Hello brown cow'
      result = att_speech.text_to_speech text, { :x_foo => 'bar' }
      FakeWeb.last_request.body.should eql text
      FakeWeb.last_request.get_fields('authorization').should eql ["Bearer 5678"]
      FakeWeb.last_request.get_fields('content-type').should eql ["text/plain"]
      FakeWeb.last_request.get_fields('accept').should eql ["audio/x-wav"]
      FakeWeb.last_request.get_fields('x-foo').should eql ["bar"]
    end
  end
end
