require File.expand_path("helpers.rb", File.dirname(__FILE__))

context "a newly created history" do
  setup do
    Coolline::History.new(path_to("history"), 10)
  end

  asserts(:size).equals 0
  asserts(:max_size).equals 10

  context "after inserting a new-line" do
    hookup do
      topic << "1"
    end

    asserts(:size).equals 1
    asserts(:max_size).equals 10

    asserts(:[], 0).equals "1"

    context "and many others" do
      hookup do
        2.upto(11) { |n| topic << n.to_s }
      end

      asserts(:size).equals 10
      asserts(:max_size).equals 10

      2.upto(11) do |n|
        asserts(:[], n - 2).equals n.to_s
      end
    end
  end

  teardown do
    File.delete path_to("history")
  end
end

context "an history from an existing file" do
  setup do
    open(path_to("history"), 'w') do |io|
      io.puts((1..13).to_a)
    end

    Coolline::History.new(path_to("history"), 15)
  end

  asserts(:size).equals 13
  asserts(:max_size).equals 15

  1.upto(13) do |n|
    asserts(:[], n - 1).equals n.to_s
  end

  asserts("search for 3") { topic.search(/3/).to_a }.equals [["13",12], ["3",2]]
  asserts("search for 3 before last line") {
    topic.search(/3/, -2).to_a
  }.equals [["3",2]]

  teardown do
    File.delete path_to("history")
  end
end

context "an history from a huge existing file" do
  setup do
    open(path_to("history"), 'w') do |io|
      io.puts((1..20).to_a)
    end

    Coolline::History.new(path_to("history"), 15)
  end

  asserts(:size).equals 15
  asserts(:max_size).equals 15

  6.upto(20) do |n|
    asserts(:[], n - 6).equals n.to_s
  end

  teardown do
    File.delete path_to("history")
  end
end
