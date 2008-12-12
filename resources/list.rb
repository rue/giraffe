require "erubis"


module Giraffe
  module Resources

    class List
      include Waves::Resources::Mixin

      # /l/ is listing of pages in repository.
      #
      # By default, HEAD is used. Optionally a full or partial commit
      # hash may be given as the second component, in which case the
      # listing is as it was at that commit.
      #
      # Lastly a subdirectory may be given, in which case only the tree
      # down from it is shown.
      #
      on(:get, ["l", {:subdir => 0..-1}]) {
        Giraffe.wiki!

        @objects =  if captured.subdir
                      Giraffe.wiki.object_for(captured.subdir.join "/").objects
                    else
                      Giraffe.wiki.objects
                    end

        @objects.map {|obj| obj.name }.join "\n"

        eruby = Erubis::Eruby.new File.read("views/list.erb")
        @content = eruby.result binding

        eruby = Erubis::Eruby.new File.read("views/layout.erb")
        eruby.result binding
      }

    end

  end
end
