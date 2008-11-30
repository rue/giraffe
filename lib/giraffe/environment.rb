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


Giraffe = OpenStruct.new unless defined? Giraffe

# Authentication
Giraffe.users     = user_config["users"] || {}

# Repository location
Giraffe.wikiroot  = File.expand_path(user_config["wikiroot"]  ||
                                     ENV["GIRAFFE_ROOT"]      ||
                                     "#{ENV["HOME"]}/wiki")

Giraffe.repo_path = File.expand_path(user_config["repo_path"] ||
                                     ENV["GIRAFFE_REPO"]      ||
                                     Giraffe.wikiroot)

Giraffe.gitdir    = File.expand_path "#{Giraffe.repo_path}/.git"
Giraffe.index     = File.expand_path "#{Giraffe.gitdir}/index"

# ruby-git needs a relative path to work with (apparently the working dir is useless.)
Giraffe.relative  = if Giraffe.wikiroot != Giraffe.repo_path
                      wiki = Pathname.new Giraffe.wikiroot
                      repo = Pathname.new Giraffe.repo_path

                      # TODO: Check that wiki is a child of repo
                      wiki.relative_path_from(repo).to_s
                    else
                      ""
                    end

Giraffe.extension = user_config["file_extension"] || ""


# Wiki setup
Giraffe.home      = "/" + (user_config["home"] || "Home")

# Some type of a link to software version used
Giraffe.itself    = (`git remote -v` =~ (/origin\s+git@(.+?)\.git/) && "http://#{$1.sub ":", "/"}/") ||
                    "http://github.com/rue/giraffe/"

# Git needs this.
require "fileutils"

begin
  Giraffe.repo = Git.open Giraffe.repo_path,
                          :repository => Giraffe.gitdir,
                          :index => Giraffe.index
rescue
  Giraffe.repo = Git.init Giraffe.repo_path, :repository => Giraffe.gitdir
  puts "Initialized repository for #{Giraffe.wikiroot}."
  puts "Git directory is in #{Giraffe.repo_path}!" if Giraffe.wikiroot != Giraffe.repo_path
end

