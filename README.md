# att_speech

![Build Status](https://secure.travis-ci.org/jsgoecke/att_speech.png)

A Ruby library for consuming the AT&T [Speech API](https://developer.att.com/developer/apiDetailPage.jsp?passedItemId=10700023) for speech to text. API details may be found [here](http://developer.att.com/developer/apiDetailPage.jsp?passedItemId=10900039).

## Installation

```
gem install att_speech
```

## Usage

```ruby
require 'att_speech'

api_key    = ENV['ATT_SPEECH_KEY']
secret_key = ENV['ATT_SPEECH_SECRET']

att_speech = ATTSpeech.new(api_key, secret_key)

# Read the audio file contents
file_contents = File.read(File.expand_path(File.dirname(File.dirname(__FILE__))) + "/bostonSeltics.wav")

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
```

## Copyright

Copyright (c) 2012 Jason Goecke. See LICENSE.txt for further details.

