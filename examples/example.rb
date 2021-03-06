$LOAD_PATH << './lib'

lp = File.join(File.dirname(File.dirname(__FILE__)), 'lib', 'att_speech.rb')
require lp

att_speech = ATTSpeech.new({ :api_key    => ENV['ATT_SPEECH_KEY'],
                             :secret_key => ENV['ATT_SPEECH_SECRET'],
                             :scope      => 'SPEECH' })

# Read the audio file contents
fp = File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), 'examples', 'bostonSeltics.wav'))
file_contents = File.read(fp)

# Blocking operation
p att_speech.speech_to_text(file_contents, type='audio/wav')

# Non-blocking operation with a future, if you have a longer file that requires more processing time
sleep 2
future = att_speech.future(:speech_to_text, file_contents, type='audio/wav')
p future.value

# Non-blocking operation that will call a block when the transcrption is returned
# Note: Remember, this is a concurrent operation so don't pass self and avoid mutable objects in the block
# from the calling context, better to have discreet actions contained in the block, such as inserting in a
# datastore
sleep 2
att_speech.speech_to_text!(file_contents) { |transcription| p transcription }
sleep 5


def write_wav_file(audio_bytes)
  file_name = "ret_audio-#{Time.now.strftime('%Y%m%d-%H%M%S')}.wav"
  full_file_name = File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), 'examples', file_name))
  audio_file = File.open(full_file_name, "w")
  audio_file << audio_bytes
  audio_file.close
end

att_text = ATTSpeech.new({ :api_key    => ENV['ATT_SPEECH_KEY'],
                           :secret_key => ENV['ATT_SPEECH_SECRET'],
                           :scope      => 'TTS' })

# Read the text file contents
tfp = File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), 'examples', 'helloWorld.txt'))
txt_contents = File.read(tfp)

audio = att_text.text_to_speech(txt_contents)
write_wav_file(audio)

# Non-blocking operation with a future, if you have a longer file that requires more processing time
sleep 2
future = att_text.future(:text_to_speech, "This is a hello world.", type='text/plain')
write_wav_file(future.value)
