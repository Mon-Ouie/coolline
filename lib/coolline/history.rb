class Coolline
  # Class used to keep track of input. It keeps a certain amount of lines at
  # most in memory, and stores them in a file.
  class History
    attr_accessor :index

    def initialize(filename, max_size = 5000)
      @io       = open_file(filename)
      @max_size = max_size

      @lines = []

      load_lines
      delete_empty
      @index = size
    end

    def reopen(filename)
      close
      @io = open_file(filename)

      load_lines
    end

    def close
      @io.close
      @lines.clear
    end

    def search(pattern, first_line = -1)
      return to_enum(:search, pattern, first_line) unless block_given?
      return if size == 0

      first_line %= size
      @lines[0..first_line].reverse_each.with_index do |line, i|
        yield line, first_line - i if pattern === line
      end
    end

    def delete_empty
      @lines.reject!(&:empty?)
    end

    def <<(el)
      @lines << el.dup
      @lines.delete_at(0) if @lines.size > @max_size

      self
    end

    def current
      self[@index]
    end

    def [](id)
      @lines[id]
    end

    def []=(id, val)
      @lines[id] = val.dup
    end

    def save_line
      @io.puts self[-1]
      @io.flush
    end

    def size
      @lines.size
    end

    attr_accessor :max_size

    private

    def load_lines
      line_count = @io.count
      @io.rewind

      if line_count < @max_size
        @lines.concat @io.map(&:chomp)
      else
        @io.each do |line| # surely inefficient
          @lines << line.chomp
          @lines.delete_at(0) if @lines.size > @max_size
        end
      end
    end

    def open_file(filename)
      dirname = File.dirname(filename)

      if !Dir.exist?(dirname)
        create_path(dirname)
      end

      File.open(filename, "a+")
    end

    def create_path(path)
      dir = File.dirname(path)

      if !Dir.exist? dir
        create_path(dir)
      end

      Dir.mkdir(path, 0700)
    end
  end
end
