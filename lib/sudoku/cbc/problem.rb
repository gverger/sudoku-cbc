module Sudoku
  module Cbc
    class Problem
      attr_accessor :initial_board, :vars_boards, :problem
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
        vars_boards.each_with_index do |var_board, index|
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

        @vars_boards = init_vars(model)
        init_constraints(model, vars_boards)
        @problem = model.to_problem
      end

      def init_vars(model)
        vars_boards = []
        (1..9).each do |value|
          vars_board = Board.new
          vars_boards << vars_board
          (0..8).each do |row|
            (0..8).each do |col|
              vars_board[row, col] = model.bin_var(name: "x_#{row}_#{col}_#{value}")
              fixed_value = initial_board[row, col]
              model.enforce("initial value (#{row}, #{col}) <- #{value}":vars_board[row, col] == 1) if fixed_value == value
            end
          end
        end
        vars_boards
      end

      def init_constraints(model, vars_boards)
        one_value_constraints(model, vars_boards)
        row_constraints(model, vars_boards)
        col_constraints(model, vars_boards)
        box_constraints(model, vars_boards)
      end

      def one_value_constraints(model, vars_boards)
        (0..8).each do |row|
          (0..8).each do |col|
            values_vars = vars_boards.map { |board| board[row, col] }
            constraint_name = "one value must be chosen for (#{row}, #{col})"
            model.enforce(constraint_name => values_vars.inject(:+) == 1)
          end
        end
      end

      def row_constraints(model, vars_boards)
        vars_boards.each_with_index do |var_board, index|
          value = index + 1
          var_board.row_values.each_with_index do |row_vars, row|
            constraint_name = "value #{value} must be present once in row #{row}"
            model.enforce(constraint_name => row_vars.inject(:+) == 1)
          end
        end
      end

      def col_constraints(model, vars_boards)
        vars_boards.each_with_index do |var_board, index|
          value = index + 1
          var_board.col_values.each_with_index do |col_vars, col|
            constraint_name = "value #{value} must be present once in col #{col}"
            model.enforce(constraint_name => col_vars.inject(:+) == 1)
          end
        end
      end

      def box_constraints(model, vars_boards)
        vars_boards.each_with_index do |var_board, index|
          value = index + 1
          var_board.box_values.each_with_index do |box_vars, box|
            constraint_name = "value #{value} must be present once in box #{box}"
            model.enforce(constraint_name => box_vars.inject(:+) == 1)
          end
        end
      end
    end
  end
end
