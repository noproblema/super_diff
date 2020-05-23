module SuperDiff
  module EqualityMatchers
    class Array < Base
      def self.applies_to?(value)
        value.class == ::Array
      end

      def fail
        <<~OUTPUT.strip
          Differing arrays.

          #{
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

      protected

      def diff
        Differs::Array.call(expected, actual, indent_level: 0)
      end
    end
  end
end
