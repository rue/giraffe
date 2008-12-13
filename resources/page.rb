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

        redirect "/l/#{@page.uri}" if @page.directory?
        redirect "/e/#{@page.uri}" unless @page.exists?

        eruby = Erubis::Eruby.new File.read("views/page.erb")
        @content = eruby.result binding

        eruby = Erubis::Eruby.new File.read("views/layout.erb")
        eruby.result binding
      }

      # Updating page resource.
      #
      on(:post, [{:path => true}]) {
        Giraffe.wiki!

        name = captured.path.pop

        @page = Giraffe::Page.from_uri captured.path, name
        @page.update! query["contents"], query["message"]

        redirect "/#{@page.uri}"
      }

    end

  end
end
