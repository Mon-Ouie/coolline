require 'io/console'
require 'unicode_utils'

class Coolline
  include ANSI

  if config_home = ENV["XDG_CONFIG_HOME"] and !config_home.empty?
    ConfigDir = File.join(config_home, "coolline")
  else
    ConfigDir = File.join(ENV["HOME"], ".config", "coolline")
  end

  if cache_home = ENV["XDG_CACHE_HOME"] and !cache_home.empty?
    CacheDir = File.join(cache_home, "coolline")
  else
    CacheDir = File.join(ENV["HOME"], ".cache", "coolline")
  end

  ConfigFile = File.join(ConfigDir, "coolline.rb")
  HistoryFile = File.join(CacheDir, "history")

  NullFile = if defined? File::NULL
               File::NULL
             else
               "/dev/null"
             end

  # @return [Hash] All the defaults settings
  Settings = {
    :word_boundaries => [" ", "-", "_"],
    :completion_word_boundaries => [" ", "-", "_"],

    :handlers =>
    [
     Handler.new(/\A(?:\C-h|\x7F)\z/, &:kill_backward_char),
     Handler.new(?\C-a, &:beginning_of_line),
     Handler.new(?\C-e, &:end_of_line),
     Handler.new(?\C-k, &:kill_line),
     Handler.new(?\C-u, &:kill_beginning_of_line),
     Handler.new(?\C-f, &:forward_char),
     Handler.new(?\C-b, &:backward_char),
     Handler.new(?\C-d, &:kill_current_char_or_leave),
     Handler.new(?\C-c) { Process.kill(:INT, Process.pid) },
     Handler.new(?\C-w, &:kill_backward_word),
     Handler.new(?\C-t, &:transpose_chars),
     Handler.new(?\C-n, &:next_history_line),
     Handler.new(?\C-p, &:previous_history_line),
     Handler.new(?\C-r, &:interactive_search),
     Handler.new(?\C-l, &:clear_screen),
     Handler.new(?\t,   &:complete),
     Handler.new(?\C-a..?\C-z) {},

     Handler.new(/\A\e(?:\C-h|\x7F)\z/, &:kill_backward_word),
     Handler.new("\eb", &:backward_word),
     Handler.new("\ef", &:forward_word),
     Handler.new("\e[A", &:previous_history_line),
     Handler.new("\e[B", &:next_history_line),
     Handler.new("\e[3~", &:kill_current_char),
     Handler.new("\e[5~", &:previous_history_line),
     Handler.new("\e[6~", &:next_history_line),
     Handler.new("\e[7~", &:beginning_of_line),
     Handler.new("\e[8~", &:end_of_line),
     Handler.new("\e[C", &:forward_char),
     Handler.new("\e[D", &:backward_char),
     Handler.new("\e[F", &:end_of_line),
     Handler.new("\e[H", &:beginning_of_line),
     Handler.new("\eOH", &:beginning_of_line),
     Handler.new("\eOF", &:end_of_line),
     Handler.new("\ed", &:kill_forward_word),
     Handler.new("\et", &:transpose_words),
     Handler.new("\ec", &:capitalize_word),
     Handler.new("\eu", &:uppercase_word),
     Handler.new("\el", &:lowercase_word),
     Handler.new("\e<", &:first_history_line),
     Handler.new("\e>", &:last_history_line),

     Handler.new(/\e.+/) {},
    ],

    :unknown_char_proc => :insert_string.to_proc,
    :transform_proc    => proc { |line| line },
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

  # Binds a key to a block. This key binding will have precedence over already
  # defined key bindings.
  #
  # @param [String] key Key code sent by the terminal
  # @yieldparam [Coolline] cool Coolline instance to use
  def self.bind(key, &action)
    Coolline::Settings[:handlers].unshift Coolline::Handler.new(key, &action)
  end

  def bind(key, &action)
    handlers.unshift Coolline::Handler.new(key, &action)
  end

  # Creates a new cool line.
  #
  # @yieldparam [Coolline] self
  def initialize
    self.class.load_config

    @input  = STDIN # must be the actual IO object
    @output = $stdout

    self.word_boundaries            = Settings[:word_boundaries].dup
    self.completion_word_boundaries = Settings[:completion_word_boundaries].dup

    self.handlers          = Settings[:handlers].dup
    self.transform_proc    = Settings[:transform_proc]
    self.unknown_char_proc = Settings[:unknown_char_proc]
    self.completion_proc   = Settings[:completion_proc]
    self.history_file      = Settings[:history_file]
    self.history_size      = Settings[:history_size]

    yield self if block_given?

    @history ||= History.new(@history_file, @history_size)

    @menu = Menu.new(@input, @output)
  end

  # @return [IO]
  attr_accessor :input, :output

  # @return [Array<String, Regexp>] Expressions detected as word boundaries for
  #   the purpose of motion commands.
  attr_reader :word_boundaries

  # @return [Regexp] Regular expression to match word boundaries
  attr_reader :word_boundaries_regexp

  def word_boundaries=(array)
    @word_boundaries = array
    @word_boundaries_regexp = /\A#{Regexp.union(*array)}\z/
  end

  # @return [Array<String, Regexp>] Expressions detected as word boundaries for
  #   the purpose of autocompletion.
  attr_accessor :completion_word_boundaries

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

  # @return [Menu]
  attr_accessor :menu

  # Perform a quick, one-off readline (equivalent to `Coolline.new.readline(...)`)
  def self.readline(*args)
    new.readline(*args)
  end

  # Reads a line from the terminal
  # @param [String] prompt Characters to print before each line
  def readline(prompt = ">> ", default_line = "")
    if @input.tty?
      readline_full(prompt, default_line)
    else
      readline_dumb(prompt)
    end
  end

  def readline_dumb(prompt)
    print prompt
    line = @input.gets
    self.line = line ? line.chomp : ""
    print transform(line), "\n"

    line.chomp if line
  end

  def readline_full(prompt = ">> ", default_line = "")
    @prompt = prompt

    @history.delete_empty

    @accumulator   = nil
    @history_moved = false
    @should_exit   = false

    self.line = default_line

    render

    @history.index = @history.size - 1
    @history << @line

    @input.raw do |raw_stdin|
      until (char = raw_stdin.getc) == "\r"
        @menu.erase

        handle(char)
        return if @should_exit

        if @history_moved
          @history_moved = false
        end

        render
      end
    end

    @menu.erase

    print "\n"

    @history[-1] = @line if @history.size != 0
    @history.index = @history.size

    @history.save_line

    @line
  end

  # Displays the current code on the terminal
  def render
    return unless @input.tty?

    width       = @input.winsize[1]
    prompt_size = ansi_length(@prompt)
    line        = transform(@line)

    stripped_line_width = ansi_length(line)
    line += " " * [width - stripped_line_width - prompt_size, 0].max

    reset_line

    width_before = UnicodeUtils.display_width @line[0..@pos]
    width_before += 1 if @pos >= @line.length

    if ansi_length(@prompt + line) <= width
      print @prompt + line
    else
      print @prompt

      left_width = width - prompt_size

      start_index = [width_before - left_width, 0].max
      end_index   = start_index + left_width

      ansi_print(line, start_index, end_index)
    end

    @menu.display
    go_to_col [prompt_size + width_before, width].
      min
  end

  # Reads a line with no prompt
  def gets
    readline ""
  end

  # Prints objects to the output.
  def print(*objs)
    @output.print(*objs)
  end

  # Closes the History object. Should be called when you're done with a Coolline
  # instance.
  def close
    @history.close
  end

  # Selects the previous line in history (if any)
  def previous_history_line
    if @history.index >= 0
      @line.replace @history[@history.index]
      @history.index -= 1
    end

    @history_moved = true
    end_of_line
  end

  # Selects the first line of history
  def first_history_line
    @history.index = 0
    @line.replace @history[0]

    @history_moved = true
    end_of_line
  end

  # Selects the next line in history (if any).
  #
  # When on the last line, this method replaces the current line with an empty
  # string.
  def next_history_line
    if @history.index + 2 < @history.size
      @history.index += 1
      @line.replace @history[@history.index + 1] || @history.current
    else
      @line.replace @history[-1]
      @history.index = @history.size - 2
    end

    @history_moved = true

    end_of_line
  end

  # Selects the last line of history
  def last_history_line
    @history.index = @history.size - 2
    @line.replace @history[@history.index]

    @history_moved = true
    end_of_line
  end

  # Prompts the user to search for a line
  def interactive_search
    found_index = @history.index

    # Use another coolline instance for the search! :D
    Coolline.new { |c|
      # Remove the search handler (to avoid nesting confusion)
      c.handlers.delete_if { |h| h.char == "\C-r" }

      # search line
      c.transform_proc = proc do
        pattern = Regexp.new Regexp.escape(c.line)

        line, found_index = @history.search(pattern, @history.index).first

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

    found_index ||= @history.index

    @line.replace @history[found_index]
    @pos = [@line.size, @pos].min

    @history.index = found_index
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

  # Sets the word at point, and moves the cursor to after the end of said word.
  def completed_word=(string)
    beg = word_beginning_before(pos)
    line[beg...pos] = string
    self.pos = beg + string.size
  end

  # @param [Array<String>] candidates
  # @return [String] The common part between all completion candidates
  def common_beginning(candidates)
    candidates.inject do |common, el|
      i = 0
      i += 1 while common[i] == el[i] and i != el.size

      el[0...i]
    end
  end

  # Tries to complete the current word
  def complete
    old_word_boundaries = word_boundaries
    self.word_boundaries = completion_word_boundaries

    return if word_boundary? line[pos - 1]

    completions = @completion_proc.call(self)

    if completions.empty?
      menu.string = "(No completions found)"
    else
      menu.list = completions
      self.completed_word = common_beginning(completions)
    end
  ensure
    self.word_boundaries = old_word_boundaries
  end

  def word_boundary?(char)
    char =~ word_boundaries_regexp
  end

  def line=(new_line)
    @line = new_line.dup
    @pos  = new_line.size

    render
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
        char == "\e" && @accumulator == "\e" or
        char == "O" && @accumulator == "\e"
      @accumulator << char
      nil
    else
      str = @accumulator + char
      @accumulator = nil

      str
    end
  end
end
