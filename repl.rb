$LOAD_PATH.unshift File.expand_path(File.join("lib", File.dirname(__FILE__)))

require 'coolline'
require 'coderay'
require 'pp'

Coolline.bind "\C-z" do |c|
  c.menu.string = "Coolline object id: #{c.object_id}"
end

cool = Coolline.new do |c|
  c.transform_proc = proc do
    CodeRay.scan(c.line, :ruby).term
  end

  c.completion_proc = proc do
    word = c.completed_word
    Object.constants.map(&:to_s).select { |w| w.start_with? word }
  end
end

# At some point, it became frustrating to just print lines without showing any
# result.

loop do
  line = cool.readline
  break if line == "exit\n"

  obj = eval(line)

  print "=> "
  pp obj
end

cool.close
