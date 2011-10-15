$LOAD_PATH.unshift File.expand_path(File.join("lib", File.dirname(__FILE__)))

require 'coolline'
require 'coderay'
require 'pp'

cool = Coolline.new do |c|
  c.transform_proc = proc do
    CodeRay.scan(c.line, :ruby).term
  end

  c.completion_proc = proc do
    word = c.line[c.word_beginning_before(c.pos)...c.pos]
    ["awesome", "aweful"].select { |w| w.start_with? word }
  end
end

# At some point, it became frustrating to just print lines without showing any
# result.

loop do
  line = cool.readline

  obj  = eval(line)

  print "=> "
  pp obj
end
