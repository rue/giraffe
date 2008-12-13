require "erubis"

module Giraffe
  module Resources

    class Search
      include Waves::Resources::Mixin

      # Search results.
      #
      on(:get, ["s", :term]) {
        # TODO: May need further guarding here.
        @matches =  Giraffe.wiki!.grep(captured.term).select {|obj, match|
                      Giraffe::Conf.list_filter.call obj.name
                    }

        eruby = Erubis::Eruby.new File.read("views/search.erb")
        @content = eruby.result binding

        eruby = Erubis::Eruby.new File.read("views/layout.erb")
        eruby.result binding
      }

      # Empty search.
      #
      on(:get, ["s"]) {
        response.status = 400
        "You must include some search term(s)! E.g. /s/term?"
      }

    end

  end
end
