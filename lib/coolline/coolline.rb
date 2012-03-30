require 'io/console'

class Coolline
  if ENV["XDG_CONFIG_HOME"]
    ConfigDir   = ENV["XDG_CONFIG_HOME"]
    ConfigFile  = File.join(ConfigDir,  "coolline.rb")
  else
    ConfigDir  = ENV["HOME"]
    ConfigFile = File.join(ConfigDir, ".coolline.rb")
  end

  HistoryFile = File.join(ConfigDir, ".coolline-history")

  NullFile = if defined? File::NULL
               File::NULL
             else
               "/dev/null"
             end

  AnsiCode = %r{(\e\[\??\d+(?:;\d+)?\w)}

  # @return [Hash] All the defaults settings
  Settings = {
    :word_boundaries => [" ", "-", "_"],

    :handlers =>
     [
      Handler.new(/\A(?:\C-h|\x7F)\z/, &:kill_backward_char),
      Handler.new( ?\C-a, &:beginning_of_line),
      Handler.new( ?\C-e, &:end_of_line),
      Handler.new( ?\C-k, &:kill_line),
      Handler.new( ?\C-f, &:forward_char),
      Handler.new( ?\C-b, &:backward_char),
      Handler.new( ?\C-d, &:kill_current_char_or_leave),
      Handler.new( ?\C-c) { Process.kill(:INT, Process.pid) },
      Handler.new( ?\C-w, &:kill_backward_word),
      Handler.new( ?\C-t, &:transpose_chars),
      Handler.new( ?\C-n, &:next_history_line),
      Handler.new( ?\C-p, &:previous_history_line),
      Handler.new( ?\C-r, &:interactive_search),
      Handler.new( ?\t,   &:complete),
      Handler.new( ?\C-a..?\C-z) {},

      Handler.new(/\A\e(?:\C-h|\x7F)\z/, &:kill_backward_word),
      Handler.new("\eb", &:backward_word),
      Handler.new("\ef", &:forward_word),
      Handler.new("\e[A", &:previous_history_line),
      Handler.new("\e[B", &:next_history_line),
      Handler.new("\e[5~", &:previous_history_line),
      Handler.new("\e[6~", &:next_history_line),
      Handler.new("\e[C", &:forward_char),
      Handler.new("\e[D", &:backward_char),
      Handler.new("\et", &:transpose_words),
      Handler.new("\ec", &:capitalize_word),
      Handler.new("\eu", &:uppercase_word),
      Handler.new("\el", &:lowercase_word),

      Handler.new(/\e.+/) {},
    ],

    :unknown_char_proc => :insert_string.to_proc,
    :transform_proc    => :line.to_proc,
    :completion_proc   => proc { |cool| [] },

    :history_file => HistoryFile,
    :history_size => 5000,
  }

  include Coolline::Editor

  @config_loaded = false

  # Loads the config, even if it has already been loaded
  def self.load_config!
    if File.exist? ConfigFile
      load ConfigFile
    end

    @config_loaded = true
  end

  # Loads the config, unless it has already been loaded
  def self.load_config
    load_config! unless @config_loaded
  end

  # Creates a new cool line.
  #
  # @yieldparam [Coolline] self
  def initialize
    self.class.load_config

    @input  = STDIN # must be the actual IO object
    @output = $stdout

    self.word_boundaries   = Settings[:word_boundaries].dup
    self.handlers          = Settings[:handlers].dup
    self.transform_proc    = Settings[:transform_proc]
    self.unknown_char_proc = Settings[:unknown_char_proc]
    self.completion_proc   = Settings[:completion_proc]
    self.history_file      = Settings[:history_file]
    self.history_size      = Settings[:history_size]

    yield self if block_given?

    @history ||= History.new(@history_file, @history_size)
  end

  # @return [IO]
  attr_accessor :input, :output

  # @return [Array<String, Regexp>] Expressions detected as word boundaries
  attr_reader :word_boundaries

  # @return [Regexp] Regular expression to match word boundaries
  attr_reader :word_boundaries_regexp

  def word_boundaries=(array)
    @word_boundaries = array
    @word_boundaries_regexp = /\A#{Regexp.union(*array)}\z/
  end

  # @return [Proc] Proc called to change the way a line is displayed
  attr_accessor :transform_proc

  # @return [Proc] Proc called to handle unmatched characters
  attr_accessor :unknown_char_proc

  # @return [Proc] Proc called to retrieve completions
  attr_accessor :completion_proc

  # @return [Array<Handler>]
  attr_accessor :handlers

  # @return [String] Name of the file containing history
  attr_accessor :history_file

  # @return [Integer] Size of the history
  attr_accessor :history_size

  # @return [History] History object
  attr_accessor :history

  # @return [String] Current line
  attr_reader :line

  # @return [Integer] Cursor position
  attr_accessor :pos

  # @return [String] Current prompt
  attr_accessor :prompt

  # Reads a line from the terminal
  # @param [String] prompt Characters to print before each line
  def readline(prompt = ">> ")
    @prompt = prompt

	@history.delete_null()
    @line        = ""
    @pos         = 0
    @accumulator = nil

    @history_moved = false

    @should_exit = false

    print "\r\e[0m\e[0K"
    print @prompt
	@history.index = @history.size - 1
	@history << @line

    until (char = @input.getch) == "\r"
      handle(char)
      return if @should_exit

      if @history_moved
        @history_moved = false
      else
        @history_index = @history.size - 1
      end
      width          = @input.winsize[1]
      prompt_size    = strip_ansi_codes(@prompt).size
      line           = transform(@line)

      stripped_line_width = strip_ansi_codes(line).size
      line << " " * [width - stripped_line_width - prompt_size, 0].max

      # reset the color, and kill the line
      print "\r\e[0m\e[0K"

      if strip_ansi_codes(@prompt + line).size <= width
        print @prompt + line
        print "\e[#{prompt_size + @pos + 1}G"
      else
        print @prompt

        left_width = width - prompt_size

        start_index = [@pos - left_width + 1, 0].max
        end_index   = start_index + left_width - 1

        i = 0
        line.split(AnsiCode).each do |str|
          if start_with_ansi_code? str
            # always print ansi codes to ensure the color is right
            print str
          else
            if i >= start_index
              print str[0..(end_index - i)]
            elsif i < start_index && i + str.size >= start_index
              print str[(start_index - i), left_width]
            end

            i += str.size
            break if i >= end_index
          end
        end
        if @pos < left_width + 1
          print "\e[#{prompt_size + @pos + 1}G"
        end
      end
    end
    print "\n"
	@history[-1] = @line
	@history.index = @history.size
    @line + "\n"
  end

  # Reads a line with no prompt
  def gets
    readline ""
  end

  # Prints objects to the output.
  def print(*objs)
    @output.print(*objs)
  end

  # Selects the previous line in history (if any)
  def previous_history_line
	if @history.index >= 0
		@line.replace @history[@history.index]
		@pos = [@line.size, @pos].min
		@history.index -= 1
		@history[-1]    = ''
    end
    @history_moved = true
	end_of_line
  end

  # Selects the next line in history (if any).
  #
  # When on the last line, this method replaces the current line with an empty
  # string.
  def next_history_line
    if @history.index + 1 < @history.size
      @history.index += 1
	  @line.replace @history[@history.index + 1]||@history.on_index
      @pos = [@line.size, @pos].min
	  @history[-1] = ''
	else
		@line.replace @history[-1]
		@history.index = @history.size - 1
		@pos = @line.size
	end
    @history_moved = true
	end_of_line
  end

  # Prompts the user to search for a line
  def interactive_search
    found_index   = @history_index

    # Use another coolline instance for the search! :D
    Coolline.new { |c|
      # Remove the search handler (to avoid nesting confusion)
      c.handlers.delete_if { |h| h.char == "\C-r" }

      # search line
      c.transform_proc = proc do
        pattern = Regexp.new Regexp.escape(c.line)

        line, found_index = @history.search(pattern, @history_index).first

        if line
          "#{c.line}): #{line}"
        else
          "#{c.line}): [pattern not found]"
        end
      end

      # Disable history
      c.history_file = NullFile
      c.history_size = 0
    }.readline("(search:")

    @line.replace @history[found_index]
    @pos = [@line.size, @pos].min

    @history_index = found_index
    @history_moved = true
  end

  def kill_current_char_or_leave
    if @line.empty?
      @should_exit = true
    else
      kill_current_char
    end
  end

  # @return [String] The string to be completed (useful in the completion proc)
  def completed_word
    line[word_beginning_before(pos)...pos]
  end

  # Tries to complete the current word
  def complete
    return if word_boundary? line[pos - 1]

    completions = @completion_proc.call(self)
    return if completions.empty?

    result = completions.inject do |common, el|
      i = 0
      i += 1 while common[i] == el[i]

      el[0...i]
    end

    beg = word_beginning_before(pos)
    line[beg...pos] = result
    self.pos = beg + result.size
  end

  def word_boundary?(char)
    char =~ word_boundaries_regexp
  end

  def strip_ansi_codes(string)
    string.gsub(AnsiCode, "")
  end

  def start_with_ansi_code?(string)
    (string =~ AnsiCode) == 0
  end

  private
  def transform(line)
    @transform_proc.call(line)
  end

  def handle(char)
    input = if @accumulator
              handle_escape(char)
            elsif char == "\e"
              @accumulator = "\e"
              nil
            else
              char
            end

    if input
      if handler = @handlers.find { |h| h === input }
        handler.call self
      else
        @unknown_char_proc.call self, char
      end
    end
  end

  def handle_escape(char)
    if char == "[" && @accumulator =~ /\A\e?\e\z/ or
        char =~ /\d/ && @accumulator =~ /\A\e?\e\[\d*\z/ or
        char == "\e" && @accumulator == "\e"
      @accumulator << char
      nil
    else
      str = @accumulator + char
      @accumulator = nil

      str
    end
  end
end
