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
    class Map

      # Normal pages have no particular prefix.
      #
      on(true, true) { to :page }

      # Empty path is the home page.
      #
      on(true, []) { request.redirect Giraffe::Conf.home, 301 }

      # /c/ is a specific commit.
      #
      #on(:get, ["c", :commit]) { to: commit }

      # /d/ is a diff file between commits to a page.
      #
      #on(:get, ["d", true]) { to :diff }

      # /e/ is an editable page.
      #
      on(true, ["e", true]) { to :editable }

      # /h/ is history of page, subdirectory or repository.
      #
      on(true, ["h", 0..-1]) { to :history }

      # /l/ is listing of pages in repository.
      #
      on(true, ["l", 0..-1]) { to :list }

      # /r/ is the raw text of a page.
      #
      on(true, ["r", true]) { to :raw }

      # /s is a search result.
      #
      on(true, ["s", 0..-1]) { to :search }

    end

  end


  # Configurations


  # Development config.
  #
  module Configurations

    class Development
      reloadable [Resources]

      application do
        use ::Rack::ShowExceptions
        use ::Rack::Static, :urls => ["/giraffe", "/favicon.ico"], :root => "public"

        run ::Waves::Dispatchers::Default.new
      end

    end

  end

end

require "giraffe"

