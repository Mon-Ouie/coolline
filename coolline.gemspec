#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$LOAD_PATH.unshift File.expand_path(File.join("lib", File.dirname(__FILE__)))

require 'coolline/version'

Gem::Specification.new do |s|
  s.name = "coolline"

  s.version = Coolline::Version

  s.summary = "Sounds like readline, smells like readline, but isn't readline"
  s.description = <<-eof
A readline-like library that allows to change how the input
is displayed.
eof

  s.homepage = "http://github.com/Mon-Ouie/coolline"

  s.email   = "mon.ouie@gmail.com"
  s.authors = ["Mon ouie"]

  s.files |= Dir["lib/**/*.rb"]
  s.files |= Dir["test/**/*.rb"]
  s.files << "repl.rb" << ".gemtest" << "LICENSE"

  s.extra_rdoc_files = ["README.md"]

  s.require_paths = %w[lib]

  s.add_development_dependency "riot"
end
