require 'fileutils'
require 'rubygems'
require 'sinatra/lib/sinatra'
require 'extensions'
require 'page'

%w(git redcloth rubypants yaml).each do |gem| 
  require_gem_with_feedback gem
end

GIT_REPO = ENV['HOME'] + '/wiki'
HOMEPAGE = 'Home'

unless File.exists?(GIT_REPO) && File.directory?(GIT_REPO)
  puts "Initializing repository in #{GIT_REPO}..."
  Git.init(GIT_REPO)
end

$repo = Git.open(GIT_REPO)

config = nil
begin
  config = YAML.load(File.read(ENV['CONFIG']))
rescue
  config = {
    'username' =>  nil,
    'password' =>  nil
  }
end

CONFIG = config