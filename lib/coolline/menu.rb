class Coolline
  # A menu allows to display some information on a rectangle below the cursor.
  #
  # It displays a string or a list of strings until the user presses another
  # key.
  class Menu
    include ANSI

    def initialize(input, output)
      @input  = input
      @output = output

      @string = ""

      @last_line_count = 0
    end

    # @return [String] Information to be displayed
    attr_accessor :string

    # Sets the menu's string to a list of items, formatted in columns.
    #
    # If some items are to wide to be showed, they will be excluded from the
    # list.
    #
    # @param [Array<String>] items
    def list=(items)
      height, width = @input.winsize

      items = items.reject { |s| ansi_length(s) > width }

      if items.empty?
        self.string = ""
      else
        col_width  = items.map { |s| ansi_length(s) }.max
        col_count  = width / col_width
        item_count = col_count * (height - 1)

        self.string = format_columns(items[0, item_count], col_count, col_width)
      end
    end

    # Renders the menu below the current line.
    #
    # This will ensure not to draw to much, so that the line currently being
    # edited will always stay visible.
    #
    # Once the menu is drawn, the cursor returns to the correct line.
    def display
      # An empty string shouldn't be treated like a 1-line string.
      return if @string.empty?

      height, width = @input.winsize

      lines = @string.lines.to_a

      lines[0, height - 1].each do |line|
        print "\n\r"
        ansi_print(line.chomp, 0, width)
      end
      reset_color

      [lines.size, height].min.times { go_to_previous_line }

      @last_line_count = [height - 1, lines.size].min
    end

    # Erases anything that had been written by the menu.
    #
    # This allows to hide the menu once it is no longer relevant.
    #
    # Notice it can only work by knowing how many lines the menu drew on the
    # screen last time it was called, and assuming the terminal size didn't
    # change.
    def erase
      return if @last_line_count.zero?

      self.string = ""

      @last_line_count.times do
        go_to_next_line
        erase_line
      end
      reset_color

      @last_line_count.times { go_to_previous_line }

      @last_line_count = 0
    end

    private

    # @param [Array<String>] items Items to show
    # @param [Integer] col_count Amount of columns to show
    # @param [Integer] col_width Width of each column
    #
    # @return [String] Items formatted appropriately
    def format_columns(items, col_count, col_width)
      string = ""

      items.each_slice(col_count) do |line|
        string << line.map { |s| s.ljust(col_width - 1) } * " " << "\n"
      end

      string
    end

    def print(*objs)
      @output.print(*objs)
    end
  end
end
