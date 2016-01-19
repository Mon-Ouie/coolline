#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require File.expand_path('../lib/coolline/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "coolline"

  s.version = Coolline::VERSION

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
  s.add_dependency "unicode_utils", "~> 1.4"

  s.add_development_dependency "riot"
end
