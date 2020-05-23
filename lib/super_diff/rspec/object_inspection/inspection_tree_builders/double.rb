module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class Double < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            value.is_a?(::RSpec::Mocks::Double)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do
              as_lines_when_rendering_to_lines(collection_bookend: :open) do
                add_text do |object|
                  inspected_class =
                    case object
                    when ::RSpec::Mocks::InstanceVerifyingDouble
                      "InstanceDouble"
                    when ::RSpec::Mocks::ClassVerifyingDouble
                      "ClassDouble"
                    when ::RSpec::Mocks::ObjectVerifyingDouble
                      "ObjectDouble"
                    else
                      "Double"
                    end

                  inspected_name =
                    object.instance_variable_get("@name") ||
                    "(anonymous)"

                  "#<#{inspected_class} #{inspected_name} "
                end

                when_rendering_to_lines do
                  add_text "{"
                end
              end

              nested do |object|
                doubled_method_names = object.__send__(:__mock_proxy).
                  instance_variable_get("@method_doubles").
                  keys

                overridden_methods =
                  doubled_method_names.reduce({}) do |hash, key|
                    hash.merge(key => object.public_send(key))
                  end

                insert_hash_inspection_of(overridden_methods)
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
