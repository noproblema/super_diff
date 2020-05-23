module SuperDiff
  module ObjectInspection
    class InspectionTree
      include Enumerable

      def initialize(disallowed_node_names: [], &block)
        @disallowed_node_names = disallowed_node_names
        @nodes = []

        if block
          instance_eval(&block)
        end
      end

      def each(&block)
        nodes.each(&block)
      end

      def before_each_callbacks
        @_before_each_callbacks ||= Hash.new { |h, k| h[k] = [] }
      end

      def render_to_string(object)
        nodes.reduce("") do |string, node|
          result = node.render_to_string(object)
          string + result
        end
      end

      def render_to_lines(object, type:, indentation_level:)
        nodes.
          each_with_index.
          reduce([TieredLines.new, "", ""]) do |
            (tiered_lines, prelude, next_prefix),
            (node, index)
          |
            result = node.render(
              object,
              preferably_as_lines: true,
              type: type,
              indentation_level: indentation_level,
            )

            if result.is_a?(Array)
              additional_lines = prefix_with(
                next_prefix,
                prepend_with(prelude, result),
              )
              [tiered_lines + additional_lines, "", ""]
            elsif result.is_a?(PrefixForNextNode)
              [tiered_lines, prelude, next_prefix + result]
            elsif tiered_lines.any?
              new_lines = tiered_lines[0..-2] + [
                tiered_lines[-1].with_value_appended(result),
              ]
              [new_lines, prelude, next_prefix]
            elsif index < nodes.size - 1
              [tiered_lines, prelude + result, ""]
            else
              new_lines = tiered_lines + [
                Line.new(
                  type: type,
                  indentation_level: indentation_level,
                  value: result,
                ),
              ]
              [new_lines, "", next_prefix]
            end
          end.
          first
      end

      def evaluate_block(object, &block)
        instance_exec(object, &block)
      end

      Nodes.registry.each do |node_class|
        define_method(node_class.method_name) do |*args, **options, &block|
          add_node(node_class, *args, **options, &block)
        end
      end

      def insert_array_inspection_of(array)
        insert_separated_list(array) do |value|
          # Passing a splatted empty hash here so that if value is a hash, we
          # force Ruby to NOT treat it like keyword args
          add_inspection_of(value, **{})
        end
      end

      def insert_hash_inspection_of(hash)
        keys = hash.keys

        format_keys_as_kwargs = keys.all? do |key|
          key.is_a?(Symbol)
        end

        insert_separated_list(keys) do |key|
          if format_keys_as_kwargs
            as_prefix_when_rendering_to_lines do
              add_text "#{key}: "
            end
          else
            as_prefix_when_rendering_to_lines do
              add_inspection_of key, as_lines: false
              add_text " => "
            end
          end

          # Passing a splatted empty hash here so that if hash[key] is a hash,
          # we force Ruby to NOT treat it like keyword args
          add_inspection_of(hash[key], **{})
        end
      end

      def insert_separated_list(enumerable, &block)
        enumerable.each_with_index do |value, index|
          as_lines_when_rendering_to_lines(
            add_comma: index < enumerable.size - 1,
          ) do
            if index > 0
              when_rendering_to_string do
                add_text " "
              end
            end

            evaluate_block(value, &block)
          end
        end
      end

      # def insert_separated_list(enumerable, separator: ",")
        # enumerable.each_with_index do |value, index|
          # if index > 0
            # if separator.is_a?(Nodes::Base)
              # append_node separator
            # else
              # add_text separator
            # end

            # add_break " "
          # end

          # yield value
        # end
      # end

      def apply_tree(tree)
        tree.each do |node|
          append_node(node.clone_with(tree: self))
        end
      end

      private

      attr_reader :disallowed_node_names, :nodes

      def add_node(node_class, *args, **options, &block)
        if disallowed_node_names.include?(node_class.name)
          raise DisallowedNodeError.create(node_name: node_class.name)
        end

        append_node(build_node(node_class, *args, **options, &block))
      end

      def append_node(node)
        nodes.push(node)
      end

      def build_node(node_class, *args, **options, &block)
        node_class.new(self, *args, **options, &block)
      end

      def prepend_with(text, result)
        if text.empty?
          result
        else
          [result[0].with_value_prepended(text)] + result[1..-1]
        end
      end

      def prefix_with(text, result)
        if text.empty?
          result
        else
          [result[0].prefixed_with(text)] + result[1..-1]
        end
      end

      class DisallowedNodeError < StandardError
        def self.create(node_name:)
          allocate.tap do |error|
            error.node_name = node_name
            error.__send__(:initialize)
          end
        end

        attr_accessor :node_name

        def initialize(_message = nil)
          super("#{node_name} is not allowed to be used here!")
        end
      end
    end
  end
end
