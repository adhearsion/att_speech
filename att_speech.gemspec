# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "att_speech"
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jason Goecke"]
  s.date = "2012-08-15"
  s.description = "A Ruby library for consuming the AT&T Speech API for speech to text."
  s.email = "jason@goecke.net"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "LICENSE.txt",
    "Rakefile",
    "VERSION",
    "lib/att_speech.rb",
    "lib/att_speech/version.rb",
    "lib/att_speech/att_speech.rb",
    "spec/att_speech_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/jsgoecke/att_speech"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "A Ruby library for consuming the AT&T Speech API https://developer.att.com/developer/apiDetailPage.jsp?passedItemId=10700023 for speech to text."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, [">= 0.8.1"])
      s.add_runtime_dependency(%q<celluloid>, [">= 0.11.1"])
      s.add_runtime_dependency(%q<hashie>, [">= 1.2.0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 2.8.0"])
      s.add_development_dependency(%q<yard>, [">= 0.7"])
      s.add_development_dependency(%q<rdoc>, [">= 3.12"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_development_dependency(%q<jeweler>, [">= 1.8.4"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<fakeweb>, [">= 0"])
    else
      s.add_dependency(%q<faraday>, [">= 0.8.1"])
      s.add_dependency(%q<celluloid>, [">= 0.11.1"])
      s.add_dependency(%q<hashie>, [">= 1.2.0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 2.8.0"])
      s.add_dependency(%q<yard>, [">= 0.7"])
      s.add_dependency(%q<rdoc>, [">= 3.12"])
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_dependency(%q<jeweler>, [">= 1.8.4"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<fakeweb>, [">= 0"])
    end
  else
    s.add_dependency(%q<faraday>, [">= 0.8.1"])
    s.add_dependency(%q<celluloid>, [">= 0.11.1"])
    s.add_dependency(%q<hashie>, [">= 1.2.0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 2.8.0"])
    s.add_dependency(%q<yard>, [">= 0.7"])
    s.add_dependency(%q<rdoc>, [">= 3.12"])
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
    s.add_dependency(%q<jeweler>, [">= 1.8.4"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<fakeweb>, [">= 0"])
  end
end

