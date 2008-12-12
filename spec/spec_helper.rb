GIRAFFE_ROOT  = File.expand_path(File.join(File.dirname(__FILE__), ".."))
GIRAFFE_LIBS  = File.join GIRAFFE_ROOT, "lib"

GIRAFFE_WAVES = File.join GIRAFFE_ROOT, "waves", "lib"


$LOAD_PATH.unshift GIRAFFE_LIBS
$LOAD_PATH.unshift GIRAFFE_ROOT
$LOAD_PATH.unshift GIRAFFE_WAVES

require "waves"
require "runtime/mocks"

require "rubygems"
  require "nokogiri"

Waves::Runtime.instance = Waves::Runtime.new
Object.send :include, Waves::Mocks

require "startup"

require "fileutils"

