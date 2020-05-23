module SuperDiff
  module EqualityMatchers
    class Hash < Base
      def self.applies_to?(value)
        value.class == ::Hash
      end

      def fail
        <<~OUTPUT.strip
          Differing hashes.

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
        Differs::Hash.call(expected, actual, indent_level: 0)
      end
    end
  end
end
