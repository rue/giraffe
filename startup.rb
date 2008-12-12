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

    class Map
      on(:get, ["list", 0..-1]) { to :list }
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
        use ::Rack::Static, :urls => ["/giraffe"], :root => "public"

        run ::Waves::Dispatchers::Default.new
      end

    end

  end

end

require "giraffe/environment"
require "giraffe/page"

