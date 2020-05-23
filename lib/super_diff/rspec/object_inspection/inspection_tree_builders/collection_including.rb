module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class CollectionIncluding < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.a_collection_including_something?(value)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do
              as_lines_when_rendering_to_lines(collection_bookend: :open) do
                add_text "#<a collection including ("
              end

              nested do |aliased_matcher|
                insert_array_inspection_of(aliased_matcher.expecteds)
              end

              as_lines_when_rendering_to_lines(collection_bookend: :close) do
                add_text ")>"
              end
            end
          end
        end
      end
    end
  end
end
