require "erubis"

module Giraffe
  module Resources

    class Editable
      include Waves::Resources::Mixin

      # Editable page in repository.
      #
      on(:get, ["e", {:path => true}]) {
        Giraffe.wiki!

        name = captured.path.pop

        @page = Giraffe::Page.from_uri captured.path, name

        eruby = Erubis::Eruby.new File.read("views/editable.erb")
        @content = eruby.result binding

        eruby = Erubis::Eruby.new File.read("views/layout.erb")
        eruby.result binding
      }

    end

  end
end
