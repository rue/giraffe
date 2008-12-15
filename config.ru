# Default rackup script to run Giraffe on Waves.
#
# Use this only if you have a running server already.
#

WAVES = ENV["WAVES"] || File.join(File.dirname(__FILE__), "waves", "lib")

$LOAD_PATH.unshift WAVES

require "waves"
require "waves/runtime/rackup"

# Rack configuration is defined along with the rest
# of it in the application itself. No point moving
# it here.
#
run Waves::Rackup.load(:startup => "run_giraffe_run.rb")

>>>>>>> Rackup file. Requires the modified Waves (included as a submodule.):config.ru
