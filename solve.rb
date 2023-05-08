#!/usr/bin/env ruby -w

require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'awesome_print'
  gem 'pry'
  gem 'pry-nav'
  gem 'terminal-table'
end

class Disc
  class InvalidDiscConfiguraion < StandardError; end

  RINGS = 4
  NUMBERS = 12

  attr_reader :numbers

  def initialize(numbers)
    @numbers = numbers

    raise InvalidDiscConfiguraion, 'Disc not valid.' unless valid?
  end

  def valid?
    numbers.size == RINGS &&
      numbers.select { |ring| ring.size == NUMBERS }.size == RINGS
  end

  def rotate!
    @numbers.each(&:rotate!)
  end
end

class DiscStack
  attr_reader :shifts, :stack

  def initialize(*disc_data)
    @stack = disc_data.map { |dd| Disc.new(dd) }
    @shifts = [0, 0, 0, 0, 0]
  end

  def to_table
    Terminal::Table.new do |t|
      t.rows = rings
      t.add_separator
      t.add_row(sums)
    end
  end

  def rotate(disc)
    #raise 'Can\'t rotate bottom disk' if disc.zero?

    shifts[disc] = shifts[disc] + 1 >= Disc::NUMBERS ? 0 : shifts[disc] + 1
    stack[disc].rotate!

    shifts
  end

  def shifts=(new_shifts)
    raise 'Number of new shifts must match old shifts!' unless new_shifts.size == shifts.size

    @shifts = new_shifts
    @shifts.each_with_index do |shift, disc|
      shift.times { stack[disc].rotate! }
    end
  end

  def sums
    rings.transpose.map { |col| col.reduce(&:+) }
  end

  private

  def rings
    discs = stack.map(&:numbers)
    Disc::RINGS.times.map do |ring|
      Disc::NUMBERS.times.map do |i|
        discs.map { |d| d[ring][i] }.reject { |n| n == :x }.last
      end
    end
  end
end

class Puzzle
  attr_reader :disc_stack

  def initialize(disc_stack)
    @attempts = 0
    @disc_stack = disc_stack
  end

  alias puz disc_stack

  def solved!
    puts 'Done.'
    puts disc_stack.to_table
    puts "#{disc_stack.shifts}"
    puts "Found on attempt #{@attempts}."
  end

  def solve1
    return solved! if all_42s?

    12.times.map.to_a.repeated_permutation(5) do |shifts|
      puz.shifts = shifts
      @attempts += 1
      solved! if all_42s?
    end
  end

  private

  def all_42s?
    disc_stack.sums.select { |s| s == 42 }.size == Disc::NUMBERS
  end
end

d1 = [
  [2, 5, 10, 7, 16, 8, 7, 8, 8, 3, 4, 12],
  [3, 3, 14, 14, 21, 21, 9, 9, 4, 4, 6, 6],
  [8, 9, 10, 11, 12, 13, 14, 15, 4, 5, 6, 7],
  [14, 11, 14, 14, 11, 14, 11, 14, 11, 11, 14, 11]
]

d2 = [
  [1, :x, 9, :x, 12, :x, 6, :x, 10, :x, 10, :x],
  [3, 26, 6, :x, 2, 13, 9, :x, 17, 19, 3, 12],
  [9, 20, 12, 3, 6, :x, 14, 12, 3, 8, 9, :x],
  [7, :x, 9, :x, 7, 14, 11, :x, 8, :x, 16, 2]
]

d3 = [
  12.times.map { :x },
  [5, :x, 10, :x, 8, :x, 22, :x, 16, :x, 9, :x],
  [21, 6, 15, 4, 9, 18, 11, 26, 14, 1, 12, :x],
  [9, 13, 9, 7, 13, 21, 17, 4, 5, :x, 7, 8]
]

d4 = [
  *2.times.map { 12.times.map { :x } },
  [4, :x, 7, 15, :x, :x, 14, :x, 9, :x, 12, :x],
  [7, 3, :x, 6, :x, 11, 11, 6, 11, :x, 6, 17]
]

d5 = [
  *3.times.map { 12.times.map { :x } },
  [3, :x, 6, :x, 10, :x, 7, :x, 15, :x, 8, :x]
]

stack = DiscStack.new(d1, d2, d3, d4, d5)
puts stack.to_table

#stack.rotate(0)
#puts stack.to_table

puz = Puzzle.new(stack)
puz.solve1

