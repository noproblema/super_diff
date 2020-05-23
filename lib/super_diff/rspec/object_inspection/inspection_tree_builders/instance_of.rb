module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class InstanceOf < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.an_instance_of_something?(value)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do
              add_text do |aliased_matcher|
                "#<an instance of #{aliased_matcher.expected}>"
              end
            end
          end
        end
      end
    end
  end
end
