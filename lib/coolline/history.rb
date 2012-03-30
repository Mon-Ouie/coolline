class Coolline
  # Class used to keep track of input. It keeps a certain amount of lines at
  # most in memory, and stores them in a file.
  class History
	attr_accessor :index
	
	def initialize(filename, max_size = 5000)
      @io       = File.open(filename, 'a+')
      @max_size = max_size

      @lines = []

      load_lines
	  delete_null
	  @index = size
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
      return to_enum(:search, pattern, first_line) unless block_given?
      return if size == 0

      first_line %= size
      @lines[0..first_line].reverse_each.with_index do |line, i|
        yield line, first_line - i if pattern === line
      end
    end

	
	def delete_null
		@lines.delete_if {|x| x == "" }
	end
	
    def <<(el)
      @io.puts el
      @io.flush

      @lines << el.dup
      @lines.delete_at(0) if @lines.size > @max_size

      self
    end

	def on_index
		return self[@index]
	end
	
    def [](id)
      @lines[id]
    end
	
	def []=(id,val)
		@lines[id] = val
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
        @lines.concat @io.lines.map(&:chomp)
      else
        @io.each do |line| # surely inefficient
          @lines << line.chomp
          @lines.delete_at(0) if @lines.size > @max_size
        end
      end
    end
  end
end
