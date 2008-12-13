require "erubis"


module Giraffe
  module Resources

    class Page
      include Waves::Resources::Mixin

      # Page in repository.
      #
      on(:get, [{:path => true}]) {
        Giraffe.wiki!

        name = captured.path.pop

        @page = Giraffe::Page.from_uri captured.path, name

#  redirect "/a/list/#{@page.uri}" if @page.directory?
#
#  if @page.exists? then show :show, @page.name else redirect "/e/" + @page.uri end

        eruby = Erubis::Eruby.new File.read("views/page.erb")
        @content = eruby.result binding

        eruby = Erubis::Eruby.new File.read("views/layout.erb")
        eruby.result binding
      }

    end

  end
end
