module SuperDiff
  module DiffFormatters
    class Collection
      ICONS = { delete: "-", insert: "+" }.freeze
      STYLES = { insert: :inserted, delete: :deleted, noop: :normal }.freeze

      def self.call(*args, &block)
        new(*args, &block).call
      end

      def initialize(
        open_token:,
        close_token:,
        operations:,
        indent_level:,
        add_comma:,
        collection_prefix:,
        build_item_prefix:
      )
        @open_token = open_token
        @close_token = close_token
        @operations = operations
        @indent_level = indent_level
        @add_comma = add_comma
        @collection_prefix = collection_prefix
        @build_item_prefix = build_item_prefix
      end

      def call
        lines.join("\n")
      end

      private

      attr_reader :open_token, :close_token, :operations, :indent_level,
        :add_comma, :collection_prefix, :build_item_prefix

      def lines
        [
          "  #{indentation}#{collection_prefix}#{open_token}",
          *contents,
          "  #{indentation}#{close_token}#{comma}",
        ]
      end

      def contents
        operations.map do |operation|
          if operation.name == :change
            operation.child_operations.to_diff(
              indent_level: indent_level + 1,
              collection_prefix: build_item_prefix.call(operation),
              add_comma: operation.should_add_comma_after_displaying?,
            )
          else
            icon = ICONS.fetch(operation.name, " ")
            style_name = STYLES.fetch(operation.name, :normal)
            chunk = build_chunk(
              operation.value,
              prefix: build_item_prefix.call(operation),
              icon: icon,
            )

            if operation.should_add_comma_after_displaying?
              chunk << ","
            end

            style_chunk(style_name, chunk)
          end
        end
      end

      def build_chunk(value, prefix:, icon:)
        inspection = ObjectInspection.inspect(
          value,
          single_line: false,
        )

        inspection.split("\n").
          map.with_index { |line, index|
            [
              icon,
              " ",
              indentation(offset: 1),
              (index == 0 ? prefix : ""),
              line
            ].join
          }.
          join("\n")
      end

      def style_chunk(style_name, chunk)
        chunk.
          split("\n").
          map { |line| Helpers.style(style_name, line) }.
          join("\n")
      end

      def indentation(offset: 0)
        "  " * (indent_level + offset)
      end

      def comma
        if add_comma
          ","
        else
          ""
        end
      end
    end
  end
end
