require 'fileutils'
require 'rubygems'
require 'sinatra/lib/sinatra'
require 'extensions'
require 'page'

%w(git rdiscount rubypants).each do |gem| 
  require_gem_with_feedback gem
end

config = {
          "username"    =>  nil,
          "password"    =>  nil,
          "repository"  => (ENV["GITWEB_REPO"] or "#{ENV["HOME"]}/wiki"),
          "home"        => "Home",
          # Try provide some reasonable "powered by"
          "gitweb_home" => (`git remote -v` =~ (/origin\s+git@(.+?)\.git/) && "http://#{$1.sub ":", "/"}/" ||
                            "http://github.com/jnewland/git-wiki/")
         }

config.merge! YAML.load_file(ENV["GITWEB_CONF"]) rescue nil


# Generate some type of a link to the current git-wiki project
GITWEB_HOME = config["gitweb_home"]

GIT_REPO    = config["repository"]
HOMEPAGE    = config["home"]

CONFIG      = config

unless File.directory? GIT_REPO
  puts "Initializing repository in #{GIT_REPO}..."
  Git.init GIT_REPO
end

$repo = Git.open GIT_REPO

