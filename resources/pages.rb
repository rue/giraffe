require "erubis"


module Giraffe
  module Resources

    class Pages
      include Waves::Resources::Mixin

      # /pages/ in repository or subdirectory.
      #
      # By default, HEAD is used. Optionally a full or partial commit
      # hash may be given as the second component, in which case the
      # listing is as it was at that commit.
      #
      # Lastly a subdirectory may be given, in which case only the tree
      # down from it is shown.
      #
      on(:get, ["pages", {:subdir => 0..-1}]) {
        Giraffe.wiki!

        @objects =  unless captured.subdir.empty?
                      Giraffe.wiki.object_for(captured.subdir.join "/").objects
                    else
                      Giraffe.wiki.objects
                    end

        eruby = Erubis::Eruby.new File.read("views/pages.erb")
        @content = eruby.result binding

        eruby = Erubis::Eruby.new File.read("views/layout.erb")
        eruby.result binding
      }

    end

  end
end
