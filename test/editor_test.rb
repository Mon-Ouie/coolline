require File.expand_path("helpers.rb", File.dirname(__FILE__))

Editor = Struct.new(:line, :pos) do
  include Coolline::Editor
end

context "editor of an empty line" do
  setup { Editor.new("", 0) }

  context "after killing previous word" do
    hookup { topic.kill_backward_word }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after inserting a word" do
    hookup { topic.insert_string "love" }

    asserts(:pos).equals 4
    asserts(:line).equals "love"
  end

  context "after moving to the next character" do
    hookup { topic.forward_char }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after moving to the previous character" do
    hookup { topic.backward_char }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after transposing characters" do
    hookup { topic.transpose_chars }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after moving one word backward" do
    hookup { topic.backward_word }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after moving one word forward" do
    hookup { topic.forward_word }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after killing the end of the line" do
    hookup { topic.kill_line }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after killing the beginning of the line" do
    hookup { topic.kill_beginning_of_line }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after transposing words" do
    hookup { topic.transpose_words }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after capitalizing word" do
    hookup { topic.capitalize_word }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after lowercasing word" do
    hookup { topic.lowercase_word }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after uppercasing word" do
    hookup { topic.uppercase_word }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end
end

context "editor before many words" do
  setup { Editor.new("a lovely dragon", 0) }

  context "after inserting a word" do
    hookup { topic.insert_string "love" }

    asserts(:pos).equals 4
    asserts(:line).equals "lovea lovely dragon"
  end

  context "after going to the end of the line" do
    hookup { topic.end_of_line }
    asserts(:pos).equals "a lovely dragon".size
  end

  context "after moving to the next character" do
    hookup { topic.forward_char }

    asserts(:pos).equals 1
    asserts(:line).equals "a lovely dragon"
  end

  context "after moving to the previous character" do
    hookup { topic.backward_char }

    asserts(:pos).equals 0
    asserts(:line).equals "a lovely dragon"
  end

  context "after moving one word backward" do
    hookup { topic.backward_word }

    asserts(:pos).equals 0
    asserts(:line).equals "a lovely dragon"
  end

  context "after moving one word forward" do
    hookup { topic.forward_word }

    asserts(:pos).equals 1
    asserts(:line).equals "a lovely dragon"
  end

  context "after killing the end of the line" do
    hookup { topic.kill_line }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after killing the beginning of the line" do
    hookup { topic.kill_beginning_of_line }

    asserts(:pos).equals 0
    asserts(:line).equals "a lovely dragon"
  end

  context "after transposing words" do
    hookup { topic.transpose_words }

    asserts(:pos).equals 0
    asserts(:line).equals "a lovely dragon"
  end

  context "after capitalizing word" do
    hookup { topic.capitalize_word }

    asserts(:pos).equals 1
    asserts(:line).equals "A lovely dragon"
  end

  context "after lowercasing word" do
    hookup { topic.lowercase_word }

    asserts(:pos).equals 1
    asserts(:line).equals "a lovely dragon"
  end

  context "after uppercasing word" do
    hookup { topic.uppercase_word }

    asserts(:pos).equals 1
    asserts(:line).equals "A lovely dragon"
  end
end

context "editor between two words" do
  setup { Editor.new("foo  bar", 4) } # NB: double space

  context "after inserting a word" do
    hookup { topic.insert_string "wow" }

    asserts(:pos).equals 7
    asserts(:line).equals "foo wow bar"
  end

  context "after killing previous word" do
    hookup { topic.kill_backward_word }

    asserts(:pos).equals 0
    asserts(:line).equals " bar"
  end

  context "after killing previous character" do
    hookup { topic.kill_backward_char }

    asserts(:pos).equals 3
    asserts(:line).equals "foo bar"
  end

  context "after moving one word backward" do
    hookup { topic.backward_word }

    asserts(:pos).equals 0
    asserts(:line).equals "foo  bar"
  end

  context "after moving one word forward" do
    hookup { topic.forward_word }

    asserts(:pos).equals "foo  bar".size
    asserts(:line).equals "foo  bar"
  end

  context "after killing the end of the line" do
    hookup { topic.kill_line }

    asserts(:pos).equals 4
    asserts(:line).equals "foo "
  end

  context "after killing the beginning of the line" do
    hookup { topic.kill_beginning_of_line }

    asserts(:pos).equals 0
    asserts(:line).equals " bar"
  end

  context "after transposing words" do
    hookup { topic.transpose_words }

    asserts(:pos).equals "bar  foo".size
    asserts(:line).equals "bar  foo"
  end

  context "after capitalizing word" do
    hookup { topic.capitalize_word }

    asserts(:pos).equals "foo  bar".size
    asserts(:line).equals "foo  Bar"
  end

  context "after lowercasing word" do
    hookup { topic.lowercase_word }

    asserts(:pos).equals "foo  bar".size
    asserts(:line).equals "foo  bar"
  end

  context "after uppercasing word" do
    hookup { topic.uppercase_word }

    asserts(:pos).equals "bar  foo".size
    asserts(:line).equals "foo  BAR"
  end
end

context "editor between two out of three words" do
  setup { Editor.new("foo bar baz", 7) }

  context "after inserting a word" do
    hookup { topic.insert_string "wow" }

    asserts(:pos).equals 10
    asserts(:line).equals "foo barwow baz"
  end

  context "after killing previous word" do
    hookup { topic.kill_backward_word }

    asserts(:pos).equals 4
    asserts(:line).equals "foo  baz"
  end

  context "after killing previous character" do
    hookup { topic.kill_backward_char }

    asserts(:pos).equals  6
    asserts(:line).equals "foo ba baz"
  end

  context "after killing current character" do
    hookup { topic.kill_current_char }

    asserts(:pos).equals  7
    asserts(:line).equals "foo barbaz"
  end

  context "after moving to the next character" do
    hookup { topic.forward_char }

    asserts(:pos).equals 8
    asserts(:line).equals "foo bar baz"
  end

  context "after moving to the previous character" do
    hookup { topic.backward_char }

    asserts(:pos).equals 6
    asserts(:line).equals "foo bar baz"
  end

  context "after transposing characters" do
    hookup { topic.transpose_chars }

    asserts(:pos).equals 8
    asserts(:line).equals "foo ba rbaz"
  end

  context "after moving one word backward" do
    hookup { topic.backward_word }

    asserts(:pos).equals 4
    asserts(:line).equals "foo bar baz"
  end

  context "after moving one word forward" do
    hookup { topic.forward_word }

    asserts(:pos).equals "foo bar baz".size
    asserts(:line).equals "foo bar baz"
  end

  context "after killing the end of the line" do
    hookup { topic.kill_line }

    asserts(:pos).equals 7
    asserts(:line).equals "foo bar"
  end

  context "after killing the beginning of the line" do
    hookup { topic.kill_beginning_of_line }

    asserts(:pos).equals 0
    asserts(:line).equals " baz"
  end

  context "after transposing words" do
    hookup { topic.transpose_words }

    asserts(:pos).equals "foo bar baz".size
    asserts(:line).equals "foo baz bar"
  end

  context "after capitalizing word" do
    hookup { topic.capitalize_word }

    asserts(:pos).equals "foo bar baz".size
    asserts(:line).equals "foo bar Baz"
  end

  context "after lowercasing word" do
    hookup { topic.lowercase_word }

    asserts(:pos).equals "foo bar baz".size
    asserts(:line).equals "foo bar baz"
  end

  context "after uppercasing word" do
    hookup { topic.uppercase_word }

    asserts(:pos).equals "bar foo baz".size
    asserts(:line).equals "foo bar BAZ"
  end
end

context "editor at the end of a line" do
  setup { Editor.new(str = "a lovely dragon", str.size) }

  context "after inserting a word" do
    hookup { topic.insert_string " here" }

    asserts(:pos).equals "a lovely dragon here".size
    asserts(:line).equals "a lovely dragon here"
  end

  context "after killing previous word" do
    hookup { topic.kill_backward_word }

    asserts(:pos).equals "a lovely ".size
    asserts(:line).equals "a lovely "
  end

  context "after going to the beginning of the line" do
    hookup { topic.beginning_of_line }
    asserts(:pos).equals 0
  end

  context "after killing previous character" do
    hookup { topic.kill_backward_char }

    asserts(:pos).equals("a lovely dragon".size - 1)
    asserts(:line).equals "a lovely drago"
  end

  context "after killing current character" do
    hookup { topic.kill_current_char }

    asserts(:pos).equals  "a lovely dragon".size
    asserts(:line).equals "a lovely dragon"
  end

  context "after moving to the next character" do
    hookup { topic.forward_char }

    asserts(:pos).equals "a lovely dragon".size
    asserts(:line).equals "a lovely dragon"
  end

  context "after moving to the previous character" do
    hookup { topic.backward_char }

    asserts(:pos).equals "a lovely dragon".size - 1
    asserts(:line).equals "a lovely dragon"
  end

  context "after transposing characters" do
    hookup { topic.transpose_chars }

    asserts(:pos).equals "a lovely dragon".size
    asserts(:line).equals "a lovely dragno"
  end

  context "after moving one word backward" do
    hookup { topic.backward_word }

    asserts(:pos).equals "a lovely ".size
    asserts(:line).equals "a lovely dragon"
  end

  context "after moving one word forward" do
    hookup { topic.forward_word }

    asserts(:pos).equals "a lovely dragon".size
    asserts(:line).equals "a lovely dragon"
  end

  context "after killing the end of the line" do
    hookup { topic.kill_line }

    asserts(:pos).equals "a lovely dragon".size
    asserts(:line).equals "a lovely dragon"
  end

  context "after killing the beginning of the line" do
    hookup { topic.kill_beginning_of_line }

    asserts(:pos).equals 0
    asserts(:line).equals ""
  end

  context "after transposing words" do
    hookup { topic.transpose_words }

    asserts(:pos).equals "a lovely dragon".size
    asserts(:line).equals "a dragon lovely"
  end

  context "after capitalizing word" do
    hookup { topic.capitalize_word }

    asserts(:pos).equals "a lovely dragon".size
    asserts(:line).equals "a lovely dragon"
  end

  context "after lowercasing word" do
    hookup { topic.lowercase_word }

    asserts(:pos).equals "a lovely dragon".size
    asserts(:line).equals "a lovely dragon"
  end

  context "after uppercasing word" do
    hookup { topic.uppercase_word }

    asserts(:pos).equals "a lovely dragon".size
    asserts(:line).equals "a lovely dragon"
  end
end

context "editor in the middle of a sentence" do
  setup { Editor.new("foo bar baz qux", 8) }

  context "after inserting a word" do
    hookup { topic.insert_string "at" }

    asserts(:pos).equals 10
    asserts(:line).equals "foo bar atbaz qux"
  end

  context "after killing previous word" do
    hookup { topic.kill_backward_word }

    asserts(:pos).equals 4
    asserts(:line).equals "foo baz qux"
  end

  context "after going to the beginning of the line" do
    hookup { topic.beginning_of_line }
    asserts(:pos).equals 0
  end

  context "after going to the end of the line" do
    hookup { topic.end_of_line }
    asserts(:pos).equals "foo bar baz qux".size
  end

  context "after killing previous character" do
    hookup { topic.kill_backward_char }

    asserts(:pos).equals 7
    asserts(:line).equals "foo barbaz qux"
  end

  context "after killing current character" do
    hookup { topic.kill_current_char }

    asserts(:pos).equals  8
    asserts(:line).equals "foo bar az qux"
  end

  context "after moving to the next character" do
    hookup { topic.forward_char }

    asserts(:pos).equals 9
    asserts(:line).equals "foo bar baz qux"
  end

  context "after moving to the previous character" do
    hookup { topic.backward_char }

    asserts(:pos).equals 7
    asserts(:line).equals "foo bar baz qux"
  end

  context "after transposing characters" do
    hookup { topic.transpose_chars }

    asserts(:pos).equals 9
    asserts(:line).equals "foo barb az qux"
  end

  context "after moving one word backward" do
    hookup { topic.backward_word }

    asserts(:pos).equals 4
    asserts(:line).equals "foo bar baz qux"
  end

  context "after moving one word forward" do
    hookup { topic.forward_word }

    asserts(:pos).equals 11
    asserts(:line).equals "foo bar baz qux"
  end

  context "after killing the end of the line" do
    hookup { topic.kill_line }

    asserts(:pos).equals 8
    asserts(:line).equals "foo bar "
  end

  context "after killing the beginning of the line" do
    hookup { topic.kill_beginning_of_line }

    asserts(:pos).equals 0
    asserts(:line).equals "baz qux"
  end

  context "after transposing words" do
    hookup { topic.transpose_words }

    asserts(:pos).equals 11
    asserts(:line).equals "foo baz bar qux"
  end

  context "after capitalizing word" do
    hookup { topic.capitalize_word }

    asserts(:pos).equals "foo bar baz".size
    asserts(:line).equals "foo bar Baz qux"
  end

  context "after lowercasing word" do
    hookup { topic.lowercase_word }

    asserts(:pos).equals "foo bar baz".size
    asserts(:line).equals "foo bar baz qux"
  end

  context "after uppercasing word" do
    hookup { topic.uppercase_word }

    asserts(:pos).equals "foo bar baz".size
    asserts(:line).equals "foo bar BAZ qux"
  end
end

context "editor in the middle of a word" do
  setup { Editor.new("foo bar baz qux", 9) }

  context "after inserting a word" do
    hookup { topic.insert_string "at" }

    asserts(:pos).equals 11
    asserts(:line).equals "foo bar bataz qux"
  end

  context "after killing previous word" do
    hookup { topic.kill_backward_word }

    asserts(:pos).equals 8
    asserts(:line).equals "foo bar az qux"
  end

  context "after going to the beginning of the line" do
    hookup { topic.beginning_of_line }
    asserts(:pos).equals 0
  end

  context "after going to the end of the line" do
    hookup { topic.end_of_line }
    asserts(:pos).equals "foo bar baz qux".size
  end

  context "after killing previous character" do
    hookup { topic.kill_backward_char }

    asserts(:pos).equals 8
    asserts(:line).equals "foo bar az qux"
  end

  context "after killing current character" do
    hookup { topic.kill_current_char }

    asserts(:pos).equals  9
    asserts(:line).equals "foo bar bz qux"
  end

  context "after moving to the next character" do
    hookup { topic.forward_char }

    asserts(:pos).equals 10
    asserts(:line).equals "foo bar baz qux"
  end

  context "after moving to the previous character" do
    hookup { topic.backward_char }

    asserts(:pos).equals 8
    asserts(:line).equals "foo bar baz qux"
  end

  context "after transposing characters" do
    hookup { topic.transpose_chars }

    asserts(:pos).equals 10
    asserts(:line).equals "foo bar abz qux"
  end

  context "after moving one word backward" do
    hookup { topic.backward_word }

    asserts(:pos).equals 8
    asserts(:line).equals "foo bar baz qux"
  end

  context "after moving one word forward" do
    hookup { topic.forward_word }

    asserts(:pos).equals 11
    asserts(:line).equals "foo bar baz qux"
  end

  context "after killing the end of the line" do
    hookup { topic.kill_line }

    asserts(:pos).equals 9
    asserts(:line).equals "foo bar b"
  end

  context "after killing the beginning of the line" do
    hookup { topic.kill_beginning_of_line }

    asserts(:pos).equals 0
    asserts(:line).equals "az qux"
  end

  context "after transposing words" do
    hookup { topic.transpose_words }

    asserts(:pos).equals 11
    asserts(:line).equals "foo baz bar qux"
  end

  context "after capitalizing word" do
    hookup { topic.capitalize_word }

    asserts(:pos).equals "foo bar baz".size
    asserts(:line).equals "foo bar bAz qux"
  end

  context "after lowercasing word" do
    hookup { topic.lowercase_word }

    asserts(:pos).equals "foo bar baz".size
    asserts(:line).equals "foo bar baz qux"
  end

  context "after uppercasing word" do
    hookup { topic.uppercase_word }

    asserts(:pos).equals "foo bar baz".size
    asserts(:line).equals "foo bar bAZ qux"
  end
end

context "editor at the end of a line with trailing whitespaces" do
  setup { Editor.new("a dragon ", 9) }

  context "after transposing words" do
    hookup { topic.transpose_words }

    asserts(:pos).equals 8
    asserts(:line).equals "dragon a "
  end
end

context "editor at the end of a one-word line with trailing whitespaces" do
  setup { Editor.new("dragon ", 7) }

  context "after transposing words" do
    hookup { topic.transpose_words }

    asserts(:pos).equals 7
    asserts(:line).equals "dragon "
  end
end

context "an editor in a mixed case word" do
  str = "Elite_cOdEr"
  setup { Editor.new(str, 3) }

    context "after capitalizing word" do
    hookup { topic.capitalize_word }

    asserts(:pos).equals str.size
    asserts(:line).equals "EliTe_coder"
  end

  context "after lowercasing word" do
    hookup { topic.lowercase_word }

    asserts(:pos).equals str.size
    asserts(:line).equals "Elite_coder"
  end

  context "after uppercasing word" do
    hookup { topic.uppercase_word }

    asserts(:pos).equals str.size
    asserts(:line).equals "EliTE_CODER"
  end
end
