module SuperDiff
  class TieredLinesElider
    extend AttrExtras.mixin
    include Helpers

    method_object :lines

    def call
      if all_lines_are_changed_or_unchanged?
        lines
      else
        elided_lines
      end
    end

    private

    def all_lines_are_changed_or_unchanged?
      sections_by_changedness.size == 1 &&
        sections_by_changedness.first.range == Range.new(0, lines.length - 1)
    end

    def elided_lines
      spans_to_elide.
        reverse.
        reduce(lines) do |lines_with_elisions, span|
          selected_lines = lines_with_elisions[span.range]
          with_slice_of_array_replaced(
            lines_with_elisions,
            span.range,
            Elision.new(
              indentation_level: span.indentation_level,
              children: selected_lines.map(&:as_elided),
            ),
          )
        end
    end

    def spans_to_elide
      # binding.pry
      sections_to_consider_for_eliding.reduce([]) do |array, section|
        array + (find_spans_to_elide_within(section) || [])
      end
    end

    def sections_to_consider_for_eliding
      sections_by_changedness.select do |section|
        section.type == :unchanged && section.range.size > threshold
      end
    end

    def sections_by_changedness
      @_sections_by_changeness ||=
        begin
          beginning =
            if (
              padded_changed_sections.empty? ||
              padded_changed_sections.first.range.begin == 0
            )
              []
            else
              [
                ChangednessSection.new(
                  type: :unchanged,
                  range: Range.new(
                    0,
                    padded_changed_sections.first.range.begin - 1
                  )
                )
              ]
            end

          middle =
            if padded_changed_sections.size == 1
              padded_changed_sections
            else
              padded_changed_sections.
                each_with_index.
                each_cons(2).
                reduce([]) do |sections, ((section1, _), (section2, index2))|
                  sections +
                  [
                    section1,
                    ChangednessSection.new(
                      type: :unchanged,
                      range: Range.new(
                        section1.range.end + 1,
                        section2.range.begin - 1,
                      )
                    )
                  ] + (
                    index2 == padded_changed_sections.size - 1 ?
                    [section2] :
                    []
                  )
                end
            end

          ending =
            if (
              padded_changed_sections.empty? ||
              padded_changed_sections.last.range.end >= lines.size - 1
            )
              []
            else
              [
                ChangednessSection.new(
                  type: :unchanged,
                  range: Range.new(
                    padded_changed_sections.last.range.end + 1,
                    lines.size - 1
                  )
                )
              ]
            end

          beginning + middle + ending
        end
    end

    def padded_changed_sections
      @_sections_by_changedness ||= lines.
        each_with_index.
        select { |line, index| line.type != :noop }.
        reduce([]) do |sections, (_, index)|
          if !sections.empty? && sections.last.range.end == index - 1
            sections[0..-2] + [sections[-1].extended_to(index)]
          else
            sections + [
              ChangednessSection.new(
                type: :changed,
                range: index..index,
              ),
            ]
          end
        end.
        map(&:padded).
        map { |section| section.capped_to(0, lines.size - 1) }.
        then(&method(:combine_congruent_sections))
    end

    def find_spans_to_elide_within(section)
      normalized_span_groups_at_decreasing_indentation_levels_within(section).
        find do |spans|
          size_before_eliding = lines[section.range].
            reject(&:complete_bookend?).
            size

          size_after_eliding =
            size_before_eliding -
            spans.sum { |span| span.range.size - 1 }

          # if section.range.size > size_before_eliding
            # binding.pry
          # end

          pp range: section.range,
             range_size: section.range.size,
             size_before_eliding: size_before_eliding,
             size_after_eliding: size_after_eliding,
             threshold: threshold

          size_before_eliding > threshold && size_after_eliding <= threshold
        end
    end

    def normalized_span_groups_at_decreasing_indentation_levels_within(section)
      span_groups_at_decreasing_indentation_levels_within(section).
        # TODO: filter it out, but still retain the total length somehow as we
        # need to factor that in when calculating whether the new length now
        # fits under the threshold
        # XXX: wait we already do that???
        map(&method(:filter_out_spans_fully_contained_in_others)).
        map(&method(:combine_adjacent_spans))
    end

    def span_groups_at_decreasing_indentation_levels_within(section)
      spans_within_section = spans.select do |span|
        span.fully_contained_within?(section)
      end

      indentation_level_thresholds = spans_within_section.
        map(&:indentation_level).
        select { |indentation_level| indentation_level > 0 }.
        uniq.
        sort.
        reverse

      indentation_level_thresholds.map do |indentation_level_threshold|
        spans_within_section.select do |span|
          span.indentation_level >= indentation_level_threshold
        end
      end
    end

    def filter_out_spans_fully_contained_in_others(spans)
      sorted_spans = spans.sort_by do |span|
        [span.indentation_level, span.range.begin, span.range.end]
      end

      spans.reject do |span2|
        sorted_spans.any? do |span1|
          !span1.equal?(span2) && span1.fully_contains?(span2)
        end
      end
    end

    def combine_adjacent_spans(spans)
      spans.reduce([]) do |combined_spans, span|
        if (
          !combined_spans.empty? &&
          span.range.begin == combined_spans.last.range.end + 1 &&
          span.indentation_level >= combined_spans.last.indentation_level
        )
          combined_spans[0..-2] + [
            combined_spans[-1].extended_to(span.range.end),
          ]
        else
          combined_spans + [span]
        end
      end
    end

    def combine_congruent_sections(sections)
      sections.reduce([]) do |combined_sections, section|
        if (
          !combined_sections.empty? &&
          section.range.begin <= combined_sections.last.range.end + 1 &&
          section.type == combined_sections.last.type
        )
          combined_sections[0..-2] + [
            combined_sections[-1].extended_to(section.range.end),
          ]
        else
          combined_sections + [section]
        end
      end
    end

    def spans
      @_spans ||= SpanBuilder.call(lines)
    end

    def threshold
      SuperDiff.configuration.diff_elision_threshold
    end

    class ChangednessSection
      extend AttrExtras.mixin

      rattr_initialize [:type!, :range!]

      def extended_to(new_end)
        self.class.new(type: type, range: range.begin..new_end)
      end

      def padded
        self.class.new(
          type: type,
          range: Range.new(range.begin - padding, range.end + padding)
        )
      end

      def capped_to(beginning, ending)
        new_beginning = range.begin < beginning ? beginning : range.begin
        new_ending = range.end > ending ? ending : range.end
        self.class.new(
          type: type,
          range: Range.new(new_beginning, new_ending),
        )
      end

      private

      def padding
        SuperDiff.configuration.diff_elision_padding || 0
      end
    end

    class SpanBuilder
      def self.call(lines)
        builder = new(lines)
        builder.build
        builder.final_spans
      end

      attr_reader :final_spans

      def initialize(lines)
        @lines = lines

        @open_collection_spans = []
        @final_spans = []
      end

      def build
        lines.each_with_index do |line, index|
          if line.opens_collection?
            open_new_collection_span(line, index)
          elsif line.closes_collection?
            extend_working_collection_span(index)
            close_working_collection_span
          else
            extend_working_collection_span(index) if open_collection_spans.any?
            record_item_span(line, index)
          end
        end
      end

      private

      attr_reader :lines, :open_collection_spans

      def extend_working_collection_span(index)
        open_collection_spans.last.extend_to(index)
      end

      def close_working_collection_span
        final_spans << open_collection_spans.pop
      end

      def open_new_collection_span(line, index)
        open_collection_spans << Span.new(
          indentation_level: line.indentation_level,
          range: index..index,
        )
      end

      def record_item_span(line, index)
        final_spans << Span.new(
          indentation_level: line.indentation_level,
          range: index..index,
        )
      end
    end

    class Span
      extend AttrExtras.mixin

      rattr_initialize [:indentation_level!, :range!]

      def fully_contains?(other)
        range.begin <= other.range.begin && range.end >= other.range.end
      end

      def fully_contained_within?(other)
        other.range.begin <= range.begin && other.range.end >= range.end
      end

      def extended_to(new_end)
        dup.tap { |clone| clone.extend_to(new_end) }
      end

      def extend_to(new_end)
        @range = range.begin..new_end
      end
    end

    class Elision
      extend AttrExtras.mixin

      rattr_initialize [:indentation_level!, :children!]

      def type
        :elision
      end

      def prefix
        ""
      end

      def value
        "# ..."
      end

      def elided?
        true
      end

      def add_comma?
        false
      end
    end
  end
end
