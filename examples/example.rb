require 'att_speech'

api_key    = 'your api key'
secret_key = 'your secret key'

att_speech = ATTSpeech.new(api_key, secret_key)

# Blocking operation
file_contents = File.read(File.expand_path(File.dirname(File.dirname(__FILE__))) + "/bostonSeltics.wav")
p att_speech.speech_to_text(file_contents, type='audio/wav')

# Non-blocking operation with a future, if you have a longer file that requires more processing time
sleep 2
future = att_speech.future(:speech_to_text, file_contents, type='audio/wav')
p future.value