require "ostruct"
require "pathname"
require "yaml"

require "rubygems"
  require "git"

user_config = if ARGV.first == "-f"
                YAML.load_file ARGV.slice!(0, 2).last
              else
                {}
              end


GitWiki = OpenStruct.new unless defined? GitWiki

# Authentication
GitWiki.users     = user_config["users"] || {}

# Repository location
GitWiki.wikiroot  = File.expand_path(user_config["wikiroot"]  ||
                                     ENV["GITWIKI_ROOT"]      ||
                                     "#{ENV["HOME"]}/wiki")

GitWiki.repo_path = File.expand_path(user_config["repo_path"] ||
                                     ENV["GITWIKI_REPO"]      ||
                                     GitWiki.wikiroot)

GitWiki.gitdir    = File.expand_path "#{GitWiki.repo_path}/.git"
GitWiki.index     = File.expand_path "#{GitWiki.gitdir}/index"

# ruby-git needs a relative path to work with (apparently the working dir is useless.)
GitWiki.relative  = if GitWiki.wikiroot != GitWiki.repo_path
                      wiki = Pathname.new GitWiki.wikiroot
                      repo = Pathname.new GitWiki.repo_path

                      # TODO: Check that wiki is a child of repo
                      wiki.relative_path_from(repo).to_s
                    else
                      ""
                    end

GitWiki.extension = user_config["file_extension"] || ""


# Wiki setup
GitWiki.home      = "/" + (user_config["home"] || "Home")

# Some type of a link to git-wiki version used
GitWiki.itself    = (`git remote -v` =~ (/origin\s+git@(.+?)\.git/) && "http://#{$1.sub ":", "/"}/") ||
                    "http://github.com/rue/git-wiki/"

# Git needs this.
require "fileutils"

begin
  GitWiki.repo = Git.open GitWiki.repo_path,
                          :repository => GitWiki.gitdir,
                          :index => GitWiki.index
rescue
  GitWiki.repo = Git.init GitWiki.repo_path, :repository => GitWiki.gitdir
  puts "Initialized repository for #{GitWiki.wikiroot}."
  puts "Git directory is in #{GitWiki.repo_path}!" if GitWiki.wikiroot != GitWiki.repo_path
end

