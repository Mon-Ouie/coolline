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
