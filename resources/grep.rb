require "erubis"

require "rubygems"
  require "rack/utils"

module Giraffe
  module Resources

    class Grep
      include Waves::Resources::Mixin

      # /grep/ for term in wiki.
      #
      # TODO: Probably horribly unsafe.
      #
      on(:get, ["grep", :term]) {
        @search = Rack::Utils.escape captured.term

        # TODO: May need further guarding here.
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
