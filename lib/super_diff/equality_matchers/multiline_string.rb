module SuperDiff
  module EqualityMatchers
    class MultilineString < Base
      def self.applies_to?(value)
        value.is_a?(::String) && value.include?("\n")
      end

      def fail
        <<~OUTPUT.strip
          Differing strings.

          #{
            # TODO: This whole thing should not be red or green, just the values
            Helpers.style(
              :alpha,
              "Expected: " +
              ObjectInspection.inspect(expected, as_lines: false),
            )
          }
          #{
            Helpers.style(
              :beta,
              "  Actual: " +
              ObjectInspection.inspect(actual, as_lines: false),
            )
          }

          Diff:

          #{diff}
        OUTPUT
      end

      private

      def diff
        Differs::MultilineString.call(expected, actual, indent_level: 0)
      end
    end
  end
end
