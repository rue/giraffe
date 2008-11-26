require 'fileutils'
require 'rubygems'
require 'sinatra/lib/sinatra'
require 'extensions'
require 'page'

%w(git rdiscount rubypants).each do |gem| 
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

# Generate some type of a link to the current git-wiki project
GITWEB_HOME = config["gitweb-home"] ||
              `git remote -v` =~ (/origin\s+git@(.+?)\.git/) && "http://#{$1.sub ":", "/"}/" ||
              "http://github.com/jnewland/git-wiki/"

CONFIG = config
