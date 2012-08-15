require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "AttSpeech" do
  FakeWeb.allow_net_connect = false
  FakeWeb.register_uri(:post, 
                       "https://api.att.com/oauth/access_token?client_id=1234&client_secret=abcd&grant_type=client_credentials&scope=SPEECH", 
                       :status => ['200', 'OK'], 
                       :body   => '{"access_token":"5678","refresh_token":"wxyz"}')
  
  FakeWeb.register_uri(:post, 
                       "https://api.att.com/rest/1/SpeechToText", 
                       :status => ['200', 'OK'], 
                       :body   => "{\"Recognition\":{\"ResponseId\":\"2b0bdcf4301f5c4aba57e2765b59bcbe\",\"NBest\":[{\"WordScores\":[1,1],\"Confidence\":1,\"Grade\":\"accept\",\"ResultText\":\"Boston celtics.\",\"Words\":[\"Boston\",\"celtics.\"],\"LanguageId\":\"en-us\",\"Hypothesis\":\"Boston celtics.\"}]}}")
  
  let(:att_speech) { att_speech = ATTSpeech.new '1234', 'abcd' }
  
  it "should create an ATTSpeech object" do
    att_speech.class.should eql ATTSpeech
  end
  
  it "should set the access_token and refresh_token" do
    att_speech.access_token.should eql '5678'
    att_speech.refresh_token.should eql 'wxyz'
  end
  
  describe 'blocking call' do
    it "should return a Hashie::Mash object when processing an audio file" do
      result = att_speech.speech_to_text 'spec/spec_helper.rb'
      result.instance_of?(Hashie::Mash).should eql true
    end
    
    it "should attempt to process an audio file" do
      result = att_speech.speech_to_text 'spec/spec_helper.rb'
      result[:recognition][:response_id].should eql '2b0bdcf4301f5c4aba57e2765b59bcbe'
      result[:recognition][:n_best][:confidence].should eql 1
    end
  end
  
  describe 'non-blocking call' do
    it "should return a Celluloid::Future object when processing an audio file" do
      future = att_speech.future(:speech_to_text, 'spec/spec_helper.rb')
      future.instance_of?(Celluloid::Future).should eql true
    end
      
    it "should allow us to user a future to process an audio file" do
      future = att_speech.future(:speech_to_text, 'spec/spec_helper.rb')
      future.value[:recognition][:response_id].should eql '2b0bdcf4301f5c4aba57e2765b59bcbe'
      future.value[:recognition][:n_best][:confidence].should eql 1
    end
  end
end
