module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      class TimeLike < Base
        def self.applies_to?(value)
          SuperDiff.time_like?(value)
        end

        TIME_FORMAT = "%Y-%m-%d %H:%M:%S.%3N %Z %:z".freeze

        def call
          InspectionTree.new do
            add_text do |time|
              "#{time.strftime(TIME_FORMAT)} (#{time.class})"
            end
          end
        end
      end
    end
  end
end
