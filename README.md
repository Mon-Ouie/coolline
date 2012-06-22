Coolline
========

Coolline is a simple readline-like library that allows you to change the way the
input is displayed while theuser is typing. This is meant to allow the
implementation of live syntax highlighting:

    require 'coolline'
    require 'coderay'
    require 'pp'

    cool = Coolline.new do |c|
      c.transform_proc = proc do
        CodeRay.scan(c.line, :ruby).term
      end

      c.completion_proc = proc do
        word = c.completed_word
        Object.constants.map(&:to_s).select { |w| w.start_with? word }
      end
    end

    loop do
      line = cool.readline

      obj  = eval(line)

      print "=> "
      pp obj
    end

Configuration
=============

Coolline automatically loads a config file before starting, which allows adding
new key bindings to it. The file is just a chunk of arbitrary ruby code located
at ``$XDG_CONFIG_HOME/coolline/coolline.rb``.

     Coolline.bind "\C-z" do |cool|
       puts "Testing key binding with #{cool}!"
     end

Installation
============

    gem install coolline --pre

Notice this needs io-console (which is part of Ruby 1.9.3).
