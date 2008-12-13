require "erubis"

module Giraffe
  module Resources

    class Grep
      include Waves::Resources::Mixin

      # /grep/ for term in wiki.
      #
      on(:get, ["grep", :term]) {
        @search = captured.term

        # TODO: May need further guarding here.
        # TODO: Definitely need to unfuck the URI-encoding (if any.)
        @matches =  Giraffe.wiki!.grep(@search).select {|obj, match|
                      Giraffe::Conf.list_filter.call obj.name
                    }

        eruby = Erubis::Eruby.new File.read("views/grep.erb")
        @content = eruby.result binding

        eruby = Erubis::Eruby.new File.read("views/layout.erb")
        eruby.result binding
      }

    end

  end
end
