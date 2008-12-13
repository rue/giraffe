require "erubis"

module Giraffe
  module Resources

    class Raw
      include Waves::Resources::Mixin

      # Raw page content.
      #
      on(:get, ["r", {:path => true}]) {
        Giraffe.wiki!

        name = captured.path.pop
        @page = Giraffe::Page.from_uri captured.path, name

        response["CONTENT-TYPE"] = "text/plain;charset=utf-8"
        response["CONTENT-DISPOSITION"] = "inline"

        @page.raw_body
      }

    end

  end
end
