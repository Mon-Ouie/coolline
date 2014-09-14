# -*- coding: utf-8 -*-
require File.expand_path("helpers.rb", File.dirname(__FILE__))

context "a user uses colors for live code highlighting" do
  setup do
    Coolline.new
  end

  context "stripping 8-color ANSI codes" do
    asserts(:strip_ansi_codes, "\033[42mLove\033[0m").equals "Love"
    asserts(:strip_ansi_codes, "\e[42mLove\e[0m").equals "Love"
  end

  context "stripping non 8-color ANSI codes" do
    asserts(:strip_ansi_codes, "\033[38;5;232mHate\033[0m").equals "Hate"
    asserts(:strip_ansi_codes, "\e[38;5;232mHate\e[0m").equals "Hate"
  end
end

context "a user uses non-tty input" do
  setup do
    Coolline.new { |c|
      c.input = StringIO.new("p 42\np 82\n")
      c.output = StringIO.new
    }
  end

  denies(:readline).raises_kind_of Exception
  asserts(:readline).equals "p 82"
  asserts(:readline).nil
end

context "printing part of a string" do
  setup {
    $stdout = StringIO.new
    extend Coolline::ANSI
  }

  context "with ASCII characters" do
    hookup { ansi_print("Hello World", 2, 9) }
    asserts { $stdout.string }.equals "llo Wor"
  end

  context "with non-ASCII characters" do
    hookup { ansi_print("Hellô Wörld", 3, 7) }
    asserts { $stdout.string }.equals "lô W"
  end

  context "with full-width characters" do
    hookup { ansi_print("日本e本語語本語本語", 3, 9) }
    asserts { $stdout.string }.equals "e本語"
  end

  context "with ANSI codes interleaved" do
    hookup { ansi_print("\e[3mH\e[42mello W\e[41morld\e[0m", 2, 9) }
    asserts { $stdout.string }.equals "\e[3m\e[42mllo W\e[41mor\e[0m"
  end
end
