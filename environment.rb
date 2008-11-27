require "ostruct"
require "yaml"

require "rubygems"
  require "git"

user_config = {}
user_config = YAML.load_file ENV["GITWIKI_CONF"] rescue nil


GitWiki = OpenStruct.new unless defined? GitWiki

# Authentication
GitWiki.users      = user_config["users"]

# Repository location
GitWiki.repo_path  = user_config["repo_path"] || ENV["GITWEB_REPO"] || "#{ENV["HOME"]}/wiki"
GitWiki.wikiroot   = user_config["wikiroot"] || ENV["GITWEB_WIKIROOT"] || GitWiki.repository

# Wiki setup
GitWiki.home       = user_config["home"] || "/Home"

# Some type of a link to git-wiki version used
GitWiki.itself     = user_config["gitwiki_page"] ||
                    `git remote -v` =~ (/origin\s+git@(.+?)\.git/) && "http://#{$1.sub ":", "/"}/" ||
                    "http://github.com/rue/git-wiki/"

# Git needs this.
require "fileutils"

begin
  GitWiki.repo = Git.open GitWiki.wikiroot, :repository => GitWiki.repo_path
rescue
  puts "Initializing repository in #{GitWiki.repo_path}."
  GitWiki.repo = Git.init GitWiki.repo_path
end

