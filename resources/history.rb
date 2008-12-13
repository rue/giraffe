require "erubis"

module Giraffe
  module Resources

    class History
      include Waves::Resources::Mixin

      # /h/ is history of objects.
      #
      # Object may be a single page, a directory or the repository.
      # By default the last 30 are shown.
      #
      on(:get, ["h", {:subdir => 0..-1}]) {
        Giraffe.wiki!

        object =  case captured.subdir.size
                  # TODO: Allow "page" for root
                  when 0
                    Giraffe.wiki
                  when 1
                    @page = Giraffe::Page.from_uri [], captured.subdir.first
                    @page.object
                  else
                    name = captured.subdir.pop
                    @page = Giraffe::Page.from_uri captured.subdir, name
                    @page.object
                  end

        @commits = object.commits 30

        eruby = Erubis::Eruby.new File.read("views/page_history.erb")
        @content = eruby.result binding

        eruby = Erubis::Eruby.new File.read("views/layout.erb")
        eruby.result binding
      }

    end

  end
end
