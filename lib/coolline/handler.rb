class Coolline
  # A handler is a simple object used to match keys.
  Handler = Struct.new(:char, :block) do
    alias old_initialize initialize
    def initialize(char, &block)
      old_initialize(char, block)
    end

    def ===(other_char)
      char === other_char
    end

    def call(cool)
      block.call(cool)
    end
  end
end
