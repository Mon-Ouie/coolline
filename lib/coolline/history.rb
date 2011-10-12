class Coolline
  class History
    def initialize(filename, max_size = 5000)
      @io       = File.open(filename, 'a+')
      @max_size = max_size

      @lines = []

      load_lines
    end

    def reopen(filename)
      close
      @io = File.open(filename, 'a+')

      load_lines
    end

    def close
      @io.close
      @lines.clear
    end

    def search(pattern, first_line = -1)
      return to_enum(:search, pattern) unless block_given?
      return if size == 0

      first_line %= size
      @lines[0..first_line].reverse_each.with_index do |line, i|
        yield line, first_line - i if pattern === line
      end
    end

    def <<(el)
      @io.puts el
      @io.flush

      @lines << el.dup
      @lines.unshift if size > @max_size

      self
    end

    def [](id)
      @lines[id]
    end

    def size
      @lines.size
    end

    attr_accessor :max_size

    private
    def load_lines
      @io.seek 0, IO::SEEK_END
      line_count = @io.lineno
      byte_index = @io.pos
      @io.rewind

      if line_count < @max_size
        @lines = @io.lines.map(&:chomp)
      else
        @io.each do |line| # surely inefficient
          self << line.chomp
        end
      end
    end
  end
end
