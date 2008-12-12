require "giraffe/git"

require "ostruct"
require "pathname"

module Giraffe

  Conf = OpenStruct.new unless defined? Conf

  # No authentication by default.
  Conf.authenticator = nil

  # Root of wiki pages and root of the repository if needed.
  Conf.wikiroot      = File.join ENV["HOME"], "wiki"
  Conf.reporoot      = Conf.wikiroot

  # Page name <-> filesystem mapping (none by default).
  Conf.to_filename   = lambda {|uri| uri }
  Conf.to_uri        = lambda {|file| file }

  Conf.list_filter   = lambda {|file| true }

  Conf.resource_filter = lambda {|uri| false }


  # Wiki setup.
  Conf.home          = "/Home"

  # Some type of a link to software version used.
  Conf.itself        = (`git remote -v` =~ (/origin\s+git@(.+?)\.git/) && "http://#{$1.sub ":", "/"}/") ||
                          "http://github.com/rue/giraffe/"

  # Load user config overrides if any, rest of ARGV goes unchanged.
  load(ENV["GIRAFFE_CONF"] || "config.rb")


  # Expand all paths just in case.
  Conf.wikiroot      = File.expand_path Conf.wikiroot
  Conf.reporoot      = File.expand_path Conf.reporoot

  # Compute relative path to wiki root if necessary.
  Conf.relative      = if Conf.wikiroot != Conf.reporoot
                            wiki = Pathname.new Conf.wikiroot
                            repo = Pathname.new Conf.reporoot

                            # TODO: Check that wiki is a child of repo
                            wiki.relative_path_from(repo).to_s
                          else
                            ""
                          end

  # Only existing repositories are allowed currently.
  Conf.wiki = Git::Repository.open Conf.wikiroot

end
