# encoding: utf-8
require 'faraday'

class AttMultipart < Faraday::Request::Multipart
  self.mime_type = 'multipart/x-srgs-audio'
end

Faraday.register_middleware :request, :att_multipart => lambda { AttMultipart }
