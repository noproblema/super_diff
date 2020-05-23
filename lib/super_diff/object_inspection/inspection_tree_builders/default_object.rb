module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      class DefaultObject < Base
        def self.applies_to?(_value)
          true
        end

        def call
          InspectionTree.new do
            when_empty do
              as_lines_when_rendering_to_lines do
                add_text do |object|
                  "#<#{object.class.name}:" +
                    SuperDiff::Helpers.object_address_for(object) +
                    ">"
                end
              end
            end

            when_non_empty do
              as_lines_when_rendering_to_lines(collection_bookend: :open) do
                add_text do |object|
                  "#<#{object.class.name}:" +
                    SuperDiff::Helpers.object_address_for(object)
                end

                when_rendering_to_lines do
                  add_text " {"
                end
              end

              when_rendering_to_string do
                add_text " "
              end

              nested do |object|
                insert_separated_list(object.instance_variables.sort) do |name|
                  as_prefix_when_rendering_to_lines do
                    add_text "#{name}="
                  end

                  add_inspection_of object.instance_variable_get(name)
                end
              end

              as_lines_when_rendering_to_lines(collection_bookend: :close) do
                when_rendering_to_lines do
                  add_text "}"
                end

                add_text ">"
              end
            end
          end
        end
      end
    end
  end
end
