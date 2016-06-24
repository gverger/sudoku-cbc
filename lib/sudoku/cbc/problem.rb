module Sudoku
  module Cbc
    class Problem
      attr_accessor :initial_board, :vars, :problem
      def initialize(board)
        @initial_board = board
      end

      def solve
        create_problem
        problem.solve
        return nil if problem.proven_infeasible?
        solution_board
      end

      def infeasibilty_reasons
        return nil unless problem.proven_infeasible?

        problem.find_conflict.map(&:function_name)
      end

      def solution_board
        sol = Board.new
        vars.each_with_index do |var_board, index|
          value = index + 1
          (0..8).each do |row|
            (0..8).each do |col|
              sol[row, col] = value if problem.value_of(var_board[row, col]) == 1
            end
          end
        end
        sol
      end

      def create_problem
        model = ::Cbc::Model.new

        @vars = init_vars(model)
        init_constraints(model, vars)
        @problem = model.to_problem
      end

      def init_vars(model)
        vars = []
        (1..9).each do |value|
          vars_board = Board.new
          vars << vars_board
          (0..8).each do |row|
            (0..8).each do |col|
              vars_board[row, col] = model.bin_var(name: "x_#{row}_#{col}_#{value}")
              fixed_value = initial_board[row, col]
              model.enforce("initial value (#{row}, #{col}) <- #{value}":vars_board[row, col] == 1) if fixed_value == value
            end
          end
        end
        vars
      end

      def init_constraints(model, vars)
        one_value_constraints(model, vars)
        row_constraints(model, vars)
        col_constraints(model, vars)
        block_constraints(model, vars)
      end

      def one_value_constraints(model, vars)
        (0..8).each do |row|
          (0..8).each do |col|
            values_vars = vars.map { |board| board[row, col] }
            constraint_name = "one value must be chosen for (#{row}, #{col})"
            model.enforce(constraint_name => values_vars.inject(:+) == 1)
          end
        end
      end

      def row_constraints(model, vars)
        vars.each_with_index do |var_board, index|
          value = index + 1
          (0..8).each do |row|
            row_vars = (0..8).map { |col| var_board[row, col] }
            constraint_name = "value #{value} must be present once in row #{row}"
            model.enforce(constraint_name => row_vars.inject(:+) == 1)
          end
        end
      end

      def col_constraints(model, vars)
        vars.each_with_index do |var_board, index|
          value = index + 1
          (0..8).each do |col|
            col_vars = (0..8).map { |row| var_board[row, col] }
            constraint_name = "value #{value} must be present once in col #{col}"
            model.enforce(constraint_name => col_vars.inject(:+) == 1)
          end
        end
      end

      def blocks
        blocks =[]
        rows_cols = [0, 1, 2].repeated_permutation(2)
        rows_cols.each do |brow, bcol|
          block = []
          rows_cols.each do |row, col|
            block << [row + 3 * brow, col + 3 * bcol]
          end
          blocks << block
        end
        blocks
      end

      def block_constraints(model, vars)
        index_blocks = blocks
        vars.each_with_index do |var_board, index|
          value = index + 1
          index_blocks.each do |block|
            block_vars = block.map { |row, col| var_board[row, col] }
            constraint_name = "value #{value} must be present once in block #{block.first}-#{block.last}"
            model.enforce(constraint_name => block_vars.inject(:+) == 1)
          end
        end
      end
    end
  end
end
