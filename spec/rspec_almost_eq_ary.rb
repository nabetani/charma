# frozen_string_literal: true

module RSpec
  module Matchers
    module BuiltIn
      class AlmostEqArray < BaseMatcher
        def initialize(expected,delta)
          @expected=expected
          @delta=delta
        end
        # @private
        def matches?(actual)
          @actual = actual
          all_numeric? && same_size? && almost_same_values?
        end
        # @api private
        # @return [String]
        def failure_message
          "expected #{actual_formatted} to #{description}#{not_same_size_clause}#{not_numeric_clause}"
        end
        # @api private
        # @return [String]
        def failure_message_when_negated
          "expected #{actual_formatted} not to #{description}"
        end
        # @api private
        # @return [String]
        def description
          "be almost equal to #{@expected} ( delta = #{@delta} )"
        end
        private

        def same_size?
          @actual.respond_to?( :size ) && @actual.size == @expected.size
        end

        def almost_same_values?
          @actual.size.times.all?{ |ix|
            (@actual[ix] - @expected[ix]).abs <= @delta
          }
        end

        def all_numeric?
          @actual.respond_to?( :all? ) && @actual.all?{ |e| e.respond_to?(:-) }
        end

        def not_same_size_clause
          ", but size differs" unless same_size?
        end

        def not_numeric_clause
          ", but it could not be treated as a numeric value" unless all_numeric?
        end

      end
    end

    def almost_eq_ary(expected, delta)
      BuiltIn::AlmostEqArray.new(expected, delta)
    end
  end
end
