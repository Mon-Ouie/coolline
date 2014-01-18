$LOAD_PATH.unshift File.expand_path(File.join("../lib"), File.dirname(__FILE__))

require 'riot'
require 'coolline'
require 'stringio'

Riot.reporter = Riot::PrettyDotMatrixReporter

TestDir = File.dirname(__FILE__)

def path_to(file)
  File.join(TestDir, file)
end
