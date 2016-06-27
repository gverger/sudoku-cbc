module Sudoku
  module Cbc
    class Board
      include Forwardable
      attr_accessor :board

      def initialize
        @board = Array.new(9) { Array.new(9, nil) }
      end

      def [](a, b)
        check_bounds a, b
        board[a][b]
      end

      def []=(a, b, value)
        check_bounds a, b
        board[a][b] = value
      end

      def row_values
        board
      end

      def col_values
        (0..8).map { |col| board.map { |row| row[col] } }
      end

      def box_values
        blocks =[]
        rows_cols = [0, 1, 2].repeated_permutation(2)
        rows_cols.each do |brow, bcol|
          blocks << rows_cols.map { |row, col| board[row + 3 * brow][col + 3 * bcol] }
        end
        blocks
      end

      def self.from_string(string)
        board = new
        row = 0
        col = 0
        string.gsub!(/\s+/, "").gsub!("\n", "")
        string.each_char do |char|
          next if char == "\s"
          board[row, col] = char.to_i unless char == "."
          col += 1
          if col == 9
            col = 0
            row += 1
          end
        end
        board
      end

      def check_bounds(*numbers)
        numbers.each do |number|
          raise "Invalid number (out of bound): #{number}" unless number.between? 0, 8
        end
      end

      def to_condensed_string
        s = ""
        board.each do |row|
          s << row.join("") << "\n"
        end
        s
      end

      def to_s
        s = "+---"*9 << "+\n| "
        board.each do |row|
          s << row.join(" | ") << " |\n"
          s << "+---"*9 << "+\n| "
        end
        s
      end
    end
  end
end
