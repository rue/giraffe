require "erubis"

module Giraffe
  module Resources

    class List
      include Waves::Resources::Mixin

      on(:get, ["list", {:subdir => 0..-1}]) {
        @objects =  if captured.subdir
                      Giraffe::Conf.wiki.object_for(captured.subdir.join "/").objects
                    else
                      Giraffe::Conf.wiki.objects
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
