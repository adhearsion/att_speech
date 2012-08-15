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

api_key    = 'foo'
secret_key = 'bar'

att_speech = ATTSpeech.new(api_key, secret_key)

# Blocking operation
p att_speech.speech_to_text('bostonSeltics.wav', type='audio/wav')
#<Hashie::Mash recognition=#<Hashie::Mash n_best=#<Hashie::Mash confidence=1 grade="accept" hypothesis="Boston celtics." language_id="en-us" result_text="Boston celtics." word_scores=[1, 1] words=["Boston", "celtics."]> response_id="452d848c6d1a4be3f2bc987e5201ae38">>

# Non-blocking operation with a future, if you have a longer file that requires more processing time
future = att_speech.future(:speech_to_text, 'bostinSeltics.wav', type='audio/wav')
p future.value
#<Hashie::Mash recognition=#<Hashie::Mash n_best=#<Hashie::Mash confidence=1 grade="accept" hypothesis="Boston celtics." language_id="en-us" result_text="Boston celtics." word_scores=[1, 1] words=["Boston", "celtics."]> response_id="452d848c6d1a4be3f2bc987e5201ae38">>
```

## Copyright

Copyright (c) 2012 Jason Goecke. See LICENSE.txt for further details.

