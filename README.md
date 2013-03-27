Coolline
========

Coolline is a readline-like library written in pure Ruby.

It offers all of the core readline features, but with a cleaner, simpler
implementation, and the ability to easily customize its behaviour.

Customizations include: modifying all key bindings, binding keys custom functions,
full control over history and tab completion, and control over what's displayed
to the user (transforms).

Usage
=====

If you don't need anything fancy, it can work like Ruby's built-in `Readline.readline`:

```ruby
result = Coolline.readline
```

But, of course you want something fancy, otherwise you'd be using `readline`!
Here's how to create a simple REPL with live syntax highlighting and tab completion:

```ruby
require 'coolline'
require 'coderay'
require 'pp'

cool = Coolline.new do |c|

  # Before the line is displayed, it gets passed through this proc,
  # which performs syntax highlighting.
  c.transform_proc = proc do
    CodeRay.scan(c.line, :ruby).term
  end

  # Add tab completion for constants (and classes)
  c.completion_proc = proc do
    word = c.completed_word
    Object.constants.map(&:to_s).select { |w| w.start_with? word }
  end

  # Alt-R should reverse the line, because we like to look at our code in the mirror
  c.bind "\er" do |cool|
    cool.line.reverse!
  end

end

loop do
  # READ
  line = cool.readline

  # EVAL
  obj = eval(line)

  # PRINT
  print "=> "
  pp obj

  # LOOP
end
```

Configuration
=============

Coolline automatically loads a config file before starting, which allows adding
new key bindings to it. The file is just a chunk of arbitrary ruby code located
at ``$XDG_CONFIG_HOME/coolline/coolline.rb``.

```ruby
Coolline.bind "\C-z" do |cool|
  puts "Testing key binding with #{cool}!"
end
```

Installation
============

    gem install coolline

Note: If your Ruby version is less than 1.9.3, you also need to install the `io-console` gem.
