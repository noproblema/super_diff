module SuperDiff
  module EqualityMatchers
    class SinglelineString < Base
      def self.applies_to?(value)
        value.class == ::String
      end

      def fail
        <<~OUTPUT.strip
          Differing strings.

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
        OUTPUT
      end
    end
  end
end
