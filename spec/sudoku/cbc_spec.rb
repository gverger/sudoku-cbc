require 'spec_helper'
module Sudoku
  module Cbc
    describe Sudoku::Cbc do
      it 'has a version number' do
        expect(Sudoku::Cbc::VERSION).not_to be nil
      end

      it "solves a sudoku board" do
        sudoku = "53..7....
                  6..195...
                  .98....6.
                  8...6...3
                  4..8.3..1
                  7...2...6
                  .6....28.
                  ...419..5
                  ....8..79"

        result = "534678912
                  672195348
                  198342567
                  859761423
                  426853791
                  713924856
                  961537284
                  287419635
                  345286179"
          .gsub(/\s+/, "")

        b = Board.from_string(sudoku)
        expect(Problem.new(b).solve.to_condensed_string.gsub(/\s+/, "")).to eq result
      end

      it "solves a sudoku board" do
        sudoku = "53..7....
                  6..195...
                  .98....6.
                  8...1...3
                  4..8.3..1
                  7...2...6
                  .6....28.
                  ...419..5
                  ....8..79"

        b = Board.from_string(sudoku)
        p = Problem.new(b)
        expect(p.solve).to be_nil
        expect(p.infeasibilty_reasons).to match ["value 1 must be present once in col 4",
                                                 "initial value (3, 4) <- 1",
                                                 "initial value (7, 4) <- 1"]
      end
    end
  end
end
