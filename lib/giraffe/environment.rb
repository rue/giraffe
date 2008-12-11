require "ostruct"
require "pathname"


Giraffe = OpenStruct.new unless defined? Giraffe

# No authentication by default.
Giraffe.authenticator = nil

# Root of wiki pages and root of the repository if needed.
Giraffe.wikiroot      = File.join ENV["HOME"], "wiki"
Giraffe.reporoot      = Giraffe.wikiroot

# Page name <-> filesystem mapping (none by default).
Giraffe.to_filename   = lambda {|uri| uri }
Giraffe.to_uri        = lambda {|file| file }

Giraffe.list_filter   = lambda {|file| true }

Giraffe.resource_filter = lambda {|uri| false }


# Wiki setup.
Giraffe.home          = "/Home"

# Some type of a link to software version used.
Giraffe.itself        = (`git remote -v` =~ (/origin\s+git@(.+?)\.git/) && "http://#{$1.sub ":", "/"}/") ||
                        "http://github.com/rue/giraffe/"

# Load user config overrides if any, rest of ARGV goes unchanged.
load ARGV.slice!(0, 2).last if ARGV.first == "-f"


# Expand all paths just in case.
Giraffe.wikiroot      = File.expand_path Giraffe.wikiroot
Giraffe.reporoot      = File.expand_path Giraffe.reporoot

# Compute relative path to wiki root if necessary.
Giraffe.relative      = if Giraffe.wikiroot != Giraffe.reporoot
                          wiki = Pathname.new Giraffe.wikiroot
                          repo = Pathname.new Giraffe.reporoot

                          # TODO: Check that wiki is a child of repo
                          wiki.relative_path_from(repo).to_s
                        else
                          ""
                        end

# Only existing repositories are allowed currently.
Giraffe.wiki = Git::Repository.open Giraffe.wikiroot

