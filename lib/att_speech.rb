%w{
	json
	faraday
	hashie
	celluloid
	active_support/core_ext/string/inflections
	att_speech/version
	att_speech/att_speech
}.each { |lib| require lib }