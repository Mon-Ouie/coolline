class Coolline
  module Editor
    # Inserts a string at the current point in the line
    #
    # @param [String] string String to be inserted
    def insert_string(string)
      line.insert pos, string
      self.pos += string.size
    end

    def word_boundary_after(pos)
      pos += 1 # don't return initial pos
      pos += 1 until pos >= line.size or word_boundary? line[pos]
      pos >= line.size ? nil : pos
    end

    def word_boundary_before(pos)
      pos -= 1
      pos -= 1 until pos < 0 or word_boundary? line[pos]
      pos < 0 ? nil : pos
    end

    def non_word_boundary_after(pos)
      pos += 1
      pos += 1 while pos < line.size and word_boundary? line[pos]
      pos >= line.size ? nil : pos
    end

    def non_word_boundary_before(pos)
      pos -= 1
      pos -= 1 while pos >= 0 and word_boundary? line[pos]
      pos < 0 ? nil : pos
    end

    def word_end_before(pos)
      pos -= 1

      if line[pos] and word_boundary? line[pos]
        non_word_boundary_before(pos) || 0
      else
        pos
      end
    end

    def word_beginning_before(pos)
      word_end = word_end_before(pos)

      if first = word_boundary_before(word_end)
        first + 1
      else
        0
      end
    end

    def word_beginning_after(pos)
      if line[pos] and word_boundary? line[pos]
        non_word_boundary_after(pos) || line.size
      else
        pos
      end
    end

    def word_end_after(pos)
      word_beg = word_beginning_after(pos)

      if first = word_boundary_after(word_beg)
        first - 1
      else
        line.size - 1
      end
    end

    # Moves the cursor to the beginning of the line
    def beginning_of_line
      self.pos = 0
    end

    # Moves to the end of the line
    def end_of_line
      self.pos = line.size
    end

    # Moves to the previous character
    def backward_char
      self.pos -= 1 if pos != 0
    end

    # Moves to the next character
    def forward_char
      self.pos += 1 if pos != line.size
    end

    # Moves to the previous word
    def backward_word
      self.pos = word_beginning_before(pos) if pos > 0
    end

    # Moves to the next word
    def forward_word
      self.pos = word_end_after(pos) + 1 if pos != line.size
    end

    # Removes the previous word
    def kill_backward_word
      if pos > 0
        beg = word_beginning_before(pos)

        line[beg...pos] = ""
        self.pos = beg
      end
    end

    # Removes the next word
    def kill_forward_word
      if pos != line.size
        ending = word_end_after(pos)

        line[pos..ending] = ""
      end
    end

    # Removes the previous character
    def kill_backward_char
      if pos > 0
        line[pos - 1] = ""
        self.pos -= 1
      end
    end

    # Removes the current character
    def kill_current_char
      line[pos] = "" if pos != line.size
    end

    # Removes all the characters beyond the current point
    def kill_line
      line[pos..-1] = ""
    end

    # Removes everything up to the current character
    def kill_beginning_of_line
      line[0...pos] = ""
      self.pos = 0
    end

    # Removes all the characters in the line
    def clear_line
      line.clear
      self.pos = 0
    end

    # Swaps the previous character with the current one
    def transpose_chars
      if line.size >= 2
        if pos == line.size
          line[pos - 2], line[pos - 1] = line[pos - 1], line[pos - 2]
        else
          line[pos - 1], line[pos] = line[pos], line[pos - 1]
          self.pos += 1
        end
      end
    end

    # Swaps the current word with the previous word, or the two previous words
    # if we're at the end of the line.
    def transpose_words
      if !non_word_boundary_after(pos)
        last = non_word_boundary_before(pos)
        return unless last

        last_beg = word_beginning_before(last)
        return unless word_boundary_before(last_beg)

        whitespace_beg = word_end_before(last_beg)
        return unless non_word_boundary_before(whitespace_beg + 1)

        first_beg = word_beginning_before(last_beg)

        line[first_beg..last] = line[last_beg..last] +
          line[(whitespace_beg + 1)...last_beg] +
          line[first_beg..whitespace_beg]

        self.pos = last + 1
      elsif word_boundary? line[pos] # between two words?
        return unless non_word_boundary_before(pos)

        last_beg = word_beginning_after(pos)
        last_end = word_end_after(pos)

        first_end = word_end_before(pos)
        first_beg = word_beginning_before(pos)

        line[first_beg..last_end] = line[last_beg..last_end] +
          line[(first_end + 1)...last_beg] +
          line[first_beg..first_end]
        self.pos = last_end + 1
      else # within a word?
        return unless non_word_boundary_before(pos)
        return unless word_boundary_before(pos)

        last_beg = word_beginning_after(pos - 1)
        last_end = word_end_after(pos)

        return unless non_word_boundary_before(last_beg)

        first_end = word_end_before(last_beg)
        first_beg = word_beginning_before(last_beg)

        line[first_beg..last_end] = line[last_beg..last_end] +
          line[(first_end + 1)...last_beg] +
          line[first_beg..first_end]
        self.pos = last_end + 1
      end
    end

    # Capitalizes the current word
    def capitalize_word
      if beg = word_beginning_after(pos) and last = word_end_after(pos)
        line[beg..last] = line[beg..last].capitalize
        self.pos = last + 1
      end
    end

    # Lowercases the current word
    def lowercase_word
      if beg = word_beginning_after(pos) and last = word_end_after(pos)
        line[beg..last] = line[beg..last].downcase
        self.pos = last + 1
      end
    end

    # Uppercases the current word
    def uppercase_word
      if beg = word_beginning_after(pos) and last = word_end_after(pos)
        line[beg..last] = line[beg..last].upcase
        self.pos = last + 1
      end
    end

    # This method can be overriden to change characters considered as word
    # boundaries.
    #
    # @return [Boolean] True if the string is a word boundary, false otherwise
    def word_boundary?(string)
      string =~ /\A[ \t]+\z/
    end
  end
end
