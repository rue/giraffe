require "erubis"


module Giraffe
  module Resources

    # Wiki page.
    #
    # Pages may be viewed, updated and created. The latter
    # two usually occur via Editable resources.
    #
    # @see Editable.
    #
    class Page
      include Waves::Resources::Mixin

      # View wiki page.
      #
      on(:get, [{:path => true}]) {
        Giraffe.wiki!

        name = captured.path.pop

        @page = Giraffe::Page.from_uri captured.path, name

        request.redirect "/pages/#{@page.uri}", 303 if @page.directory?
        request.redirect "/editable/#{@page.uri}", 303 unless @page.exists?

        eruby = Erubis::Eruby.new File.read("views/page.erb")
        @content = eruby.result binding

        eruby = Erubis::Eruby.new File.read("views/layout.erb")
        eruby.result binding
      }

      # Create new wiki page.
      #
      # NOTE: The PUT request is simulated using a hidden input field,
      #       but it works fine for our purposes. See views/editable.erb.
      #
      on(:put, [{:path => true}]) {
        Giraffe.wiki!

        name = captured.path.pop

        @page = Giraffe::Page.from_uri captured.path, name
        response.status = 400 and return "400 Bad Request" if @page.exists?
        @page.create! query["contents"], query["message"]

        # TODO: This *should* be 201
        request.redirect "/#{@page.uri}", 302
      }

      # Update existing page resource.
      #
      on(:post, [{:path => true}]) {
        Giraffe.wiki!

        name = captured.path.pop

        @page = Giraffe::Page.from_uri captured.path, name
        response.status = 400 and return "400 Bad Request" unless @page.exists?
        @page.update! query["contents"], query["message"]

        # TODO: This *should* be 201
        request.redirect "/#{@page.uri}", 302
      }

    end

  end
end
