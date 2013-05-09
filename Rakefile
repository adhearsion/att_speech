# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "att_speech"
  gem.homepage = "http://github.com/jsgoecke/att_speech"
  gem.license = "MIT"
  gem.summary = %Q{A Ruby library for consuming the AT&T Speech API https://developer.att.com/developer/forward.jsp?passedItemId=12500023 for speech->text, and text->speech.}
  gem.description = %Q{A Ruby library for consuming v3 of the AT&T Speech API for speech->text, and text->speech. Takes in either .wav or specific other audio files, and returns a text string of the spoken words. Can also take in either a text string or .txt file and returns a string of bytes from which a .wav file can be created of the spoken text.}
  gem.email = "jason@goecke.net"
  gem.authors = ["Jason Goecke, Peter Wilson"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
