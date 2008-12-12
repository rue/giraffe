
lib_dir = File.join(File.dirname(__FILE__), "lib")
$LOAD_PATH.unshift(lib_dir) if File.directory?(lib_dir)

require "sinatra/lib/sinatra"

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => ENV['RACK_ENV'],
  :raise_errors => true
)

require 'giraffe'

run Sinatra.application
