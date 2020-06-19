require "super_diff"

module SuperDiff
  module RSpec
    autoload :AugmentedMatcher, "super_diff/rspec/augmented_matcher"
    autoload :Configuration, "super_diff/rspec/configuration"
    autoload :Differ, "super_diff/rspec/differ"
    autoload :Differs, "super_diff/rspec/differs"
    autoload :MatcherTextBuilders, "super_diff/rspec/matcher_text_builders"
    autoload :MatcherTextTemplate, "super_diff/rspec/matcher_text_template"
    autoload :ObjectInspection, "super_diff/rspec/object_inspection"
    autoload :OperationTreeBuilders, "super_diff/rspec/operation_tree_builders"

    def self.configure(&block)
      SuperDiff.configure(&block)
    end

    def self.configuration
      SuperDiff.configuration
    end

    def self.a_hash_including_something?(value)
      fuzzy_object?(value) &&
        value.respond_to?(:expecteds) &&
        value.expecteds.one? &&
        value.expecteds.first.is_a?(::Hash)
    end

    def self.a_collection_including_something?(value)
      fuzzy_object?(value) &&
        value.respond_to?(:expecteds) &&
        !(value.expecteds.one? && value.expecteds.first.is_a?(::Hash))
    end

    def self.an_object_having_some_attributes?(value)
      fuzzy_object?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::HaveAttributes)
    end

    def self.a_collection_containing_exactly_something?(value)
      fuzzy_object?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::ContainExactly)
    end

    def self.a_kind_of_something?(value)
      fuzzy_object?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::BeAKindOf)
    end

    def self.an_instance_of_something?(value)
      fuzzy_object?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::BeAnInstanceOf)
    end

    def self.a_value_within_something?(value)
      fuzzy_object?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::BeWithin)
    end

    def self.fuzzy_object?(value)
      value.is_a?(::RSpec::Matchers::AliasedMatcher)
    end

    SuperDiff.configuration.tap do |config|
      config.add_extra_differ_classes(
        Differs::CollectionContainingExactly,
        Differs::CollectionIncluding,
        Differs::HashIncluding,
        Differs::ObjectHavingAttributes,
      )

      config.add_extra_operation_tree_builder_classes(
        OperationTreeBuilders::CollectionContainingExactly,
        OperationTreeBuilders::CollectionIncluding,
        OperationTreeBuilders::HashIncluding,
        OperationTreeBuilders::ObjectHavingAttributes,
      )

      config.add_extra_inspection_tree_builder_classes(
        ObjectInspection::InspectionTreeBuilders::Double,
        ObjectInspection::InspectionTreeBuilders::CollectionContainingExactly,
        ObjectInspection::InspectionTreeBuilders::CollectionIncluding,
        ObjectInspection::InspectionTreeBuilders::HashIncluding,
        ObjectInspection::InspectionTreeBuilders::InstanceOf,
        ObjectInspection::InspectionTreeBuilders::KindOf,
        ObjectInspection::InspectionTreeBuilders::ObjectHavingAttributes,
        # ObjectInspection::InspectionTreeBuilders::Primitive,
        ObjectInspection::InspectionTreeBuilders::ValueWithin,
      )
    end
  end
end

require_relative "rspec/monkey_patches"
