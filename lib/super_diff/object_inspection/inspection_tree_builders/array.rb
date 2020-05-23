module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      class Array < Base
        def self.applies_to?(value)
          value.is_a?(::Array)
        end

        def call
          InspectionTree.new do
            when_empty do
              as_lines_when_rendering_to_lines do
                add_text "[]"
              end
            end

            when_non_empty do |array|
              as_lines_when_rendering_to_lines(collection_bookend: :open) do
                add_text "["
              end

              nested do
                insert_array_inspection_of(array)
              end

              as_lines_when_rendering_to_lines(collection_bookend: :close) do
                add_text "]"
              end
            end
          end
        end
      end
    end
  end
end
