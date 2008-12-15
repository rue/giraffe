require "giraffe/git"
require "giraffe/page"

require "ostruct"
require "pathname"


module Giraffe

  class << self

    # Configuration
    #
    attr_accessor :wikiroot,
                  :reporoot,

                  :to_filename,
                  :to_uri,

                  :list_filter,
                  :resource_filter,

                  :home,

                  :authenticator,

                  :itself

    # Wiki object
    #
    attr_reader   :wiki

  end

  # Default configuration
  #
  def self.reload()
    # No authentication by default.
    self.authenticator    = nil

    # Root of wiki pages and root of the repository if needed.
    self.wikiroot         = File.join ENV["HOME"], "wiki"
    self.reporoot         = wikiroot

    # Page name <-> filesystem mapping (none by default).
    self.to_filename      = lambda {|uri| uri }
    self.to_uri           = lambda {|file| file }

    self.list_filter      = lambda {|file| true }
    self.resource_filter  = lambda {|uri| false }

    # Wiki setup.
    self.home             = "/Home"

    # Some type of a link to software version used.
    self.itself           = (`git remote -v` =~ (/origin\s+git@(.+?)\.git/) && "http://#{$1.sub ":", "/"}/") ||
                             "http://github.com/rue/giraffe/"

# Load user config overrides if any, rest of ARGV goes unchanged.

    load(ENV["GIRAFFE_CONF"] || "config.rb")

    # Expand all paths just in case.
    self.wikiroot      = File.expand_path wikiroot
    self.reporoot      = File.expand_path reporoot
  end


  # Load the wiki.
  #
  # By default loads HEAD but can be given a commit
  # to load from instead.
  #
  def self.wiki!(commit = "HEAD")
    reload
    @wiki = Git::Repository.open wikiroot, commit
  end

end

