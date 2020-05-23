module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class KindOf < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.a_kind_of_something?(value)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do
              add_text do |aliased_matcher|
                "#<a kind of #{aliased_matcher.expected}>"
              end
            end
          end
        end
      end
    end
  end
end
