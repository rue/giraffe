require "foundations/compact"
require "autocode"

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")


module Giraffe
  include Waves::Foundations::Compact

  # All of our resources live here.
  #
  module Resources
    include AutoCode

    auto_load true, :directories => "resources"

    # First-tier resource mapper.
    #
    # Requests are forwarded to the correct Resource, which
    # then deals with accepted methods and further resolution.
    #
    # Since the matching is done sequentially, the most commonly
    # used resources are toward the bottom. The exception to this
    # are naturally the prefixless page paths which match last
    # (and are obviously the most common..oh, the competition.)
    #
    # NOTE: If hoarding the names from the front of the path is a
    #       problem (e.g. you want to have a page named "commit"
    #       for whatever silly reason), consider transforming
    #       the filenames to use WikiCase for URIs. I.e.,
    #
    #           /commit => some commit resource
    #
    #       but
    #
    #           /Commit => commit.txt     # Or whatever
    #
    class Map

      # Normal pages have no particular prefix.
      #
      on(true, ["wiki", true]) { to :page }

      # Empty path is the home page.
      #
      on(true, []) {
        Giraffe.wiki!
        request.redirect Giraffe::Conf.home, 301
      }

      # /commit/ is a specific commit.
      #
      #on(:get, ["commit", :sha]) { to: commit }

      # /diff/ from an earlier to current version.
      #
      #on(:get, ["diff", true]) { to :diff }

      # /raw/ text corresponding to a page's source.
      #
      on(true, ["raw", true]) { to :raw }

      # /changes/ to the file, directory or repository as commits.
      #
      on(true, ["changes", 0..-1]) { to :changes }

      # /search/ results for term given in the path.
      #
      on(true, ["search", true]) { to :search }

      # /pages/ in the repository or a subdirectory.
      #
      on(true, ["pages", 0..-1]) { to :list }

      # /editable/ page that can be used to update the real page.
      #
      on(true, ["editable", true]) { to :editable }

    end

  end


  # Configurations


  # Development config.
  #
  module Configurations

    class Development
      reloadable [Resources]

      host  "0.0.0.0"
      port  8080

      application do
        use ::Rack::ShowExceptions
        use ::Rack::Static, :urls => ["/giraffe", "/favicon.ico"], :root => "public"

        run ::Waves::Dispatchers::Default.new
      end

    end

  end

end

require "giraffe"

