module SuperDiff
  class Configuration
    attr_reader(
      :extra_differ_classes,
      :extra_operation_tree_builder_classes,
      :extra_operation_tree_classes,
      :extra_diff_formatter_classes,
      :extra_inspection_tree_builder_classes,
      :diff_elision_threshold,
      :diff_elision_padding,
    )

    def initialize(options = {})
      @extra_differ_classes = [].freeze
      @extra_operation_tree_builder_classes = [].freeze
      @extra_operation_tree_classes = [].freeze
      @extra_diff_formatter_classes = [].freeze
      @extra_inspection_tree_builder_classes = [].freeze
      @color_enabled = color_enabled_by_default?
      @diff_elision_enabled = false
      @diff_elision_threshold = nil
      @diff_elision_padding = nil

      merge!(options)
    end

    def initialize_dup(original)
      super
      @extra_differ_classes = original.extra_differ_classes.dup.freeze
      @extra_operation_tree_builder_classes =
        original.extra_operation_tree_builder_classes.dup.freeze
      @extra_operation_tree_classes =
        original.extra_operation_tree_classes.dup.freeze
      @extra_diff_formatter_classes =
        original.extra_diff_formatter_classes.dup.freeze
      @extra_inspection_tree_builder_classes =
        original.extra_inspection_tree_builder_classes.dup.freeze
    end

    def merge!(configuration_or_options)
      options =
        if configuration_or_options.is_a?(self.class)
          configuration_or_options.to_h
        else
          configuration_or_options
        end

      options.each do |key, value|
        case key
        when :extra_differ_classes
          @extra_differ_classes = (
            extra_differ_classes +
            value
          ).freeze
        when :extra_operation_tree_builder_classes
          @extra_operation_tree_builder_classes = (
            extra_operation_tree_builder_classes +
            value
          ).freeze
        when :extra_diff_formatter_classes
          @extra_diff_formatter_classes = (
            extra_diff_formatter_classes +
            value
          ).freeze
        when :color_enabled
          @color_enabled = value
        when :diff_elision_enabled
          @diff_elision_enabled = value
        when :diff_elision_threshold
          @diff_elision_threshold = value
        when :diff_elision_padding
          @diff_elision_padding = value
        end
      end

      updated
    end

    def add_extra_differ_classes(*classes)
      @extra_differ_classes = (@extra_differ_classes + classes).freeze
    end
    alias_method :add_extra_differ_class, :add_extra_differ_classes

    def add_extra_operation_tree_builder_classes(*classes)
      @extra_operation_tree_builder_classes =
        (@extra_operation_tree_builder_classes + classes).freeze
    end
    alias_method(
      :add_extra_operation_tree_builder_class,
      :add_extra_operation_tree_builder_classes,
    )

    def add_extra_operation_tree_classes(*classes)
      @extra_operation_tree_classes =
        (@extra_operation_tree_classes + classes).freeze
    end
    alias_method(
      :add_extra_operation_tree_class,
      :add_extra_operation_tree_classes,
    )

    def add_extra_diff_formatter_classes(*classes)
      @extra_diff_formatter_classes =
        (@extra_diff_formatter_classes + classes).freeze
    end
    alias_method(
      :add_extra_diff_formatter_class,
      :add_extra_diff_formatter_classes,
    )

    def add_extra_inspection_tree_builder_classes(*classes)
      @extra_inspection_tree_builder_classes =
        (@extra_inspection_tree_builder_classes + classes).freeze
    end
    alias_method(
      :add_extra_inspector_class,
      :add_extra_inspection_tree_builder_classes,
    )

    def color_enabled?
      @color_enabled
    end

    def diff_elision_enabled?
      @diff_elision_enabled
    end

    def updated
      SuperDiff::Csi.color_enabled = color_enabled?
    end

    def to_h
      {
        extra_differ_classes: extra_differ_classes.dup,
        extra_operation_tree_builder_classes: extra_operation_tree_builder_classes.dup,
        extra_operation_tree_classes: extra_operation_tree_classes.dup,
        extra_diff_formatter_classes: extra_diff_formatter_classes.dup,
        extra_inspection_tree_builder_classes: extra_inspection_tree_builder_classes.dup,
        color_enabled: color_enabled?,
        diff_elision_enabled: diff_elision_enabled?,
        diff_elision_threshold: diff_elision_threshold,
        diff_elision_padding: diff_elision_padding,
      }
    end

    private

    def color_enabled_by_default?
      $stdout.respond_to?(:tty?) && $stdout.tty?
    end
  end
end
