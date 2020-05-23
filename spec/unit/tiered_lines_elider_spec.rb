require "spec_helper"

RSpec.describe SuperDiff::TieredLinesElider, type: :unit do
  context "and there is a sequence of noops that does not span more than some threshold of lines" do
    it "doesn't elide anything" do
      # Diff:
      #
      #   [
      #     "one",
      #     "two",
      #     "three",
      # -   "four",
      # +   "FOUR",
      #     "six",
      #     "seven",
      #     "eight",
      #   ]

      lines = [
        line(
          type: :noop,
          indentation_level: 0,
          value: %([),
          collection_bookend: :open,
          complete_bookend: :open,
        ),
        line(
          type: :noop,
          indentation_level: 1,
          value: %("one"),
          add_comma: true,
        ),
        line(
          type: :noop,
          indentation_level: 1,
          value: %("two"),
          add_comma: true,
        ),
        line(
          type: :noop,
          indentation_level: 1,
          value: %("three"),
          add_comma: true,
        ),
        line(
          type: :delete,
          indentation_level: 1,
          value: %("four"),
          add_comma: true,
        ),
        line(
          type: :insert,
          indentation_level: 1,
          value: %("FOUR"),
          add_comma: true,
        ),
        line(
          type: :noop,
          indentation_level: 1,
          value: %("five"),
          add_comma: true,
        ),
        line(
          type: :noop,
          indentation_level: 1,
          value: %("six"),
          add_comma: true,
        ),
        line(
          type: :noop,
          indentation_level: 1,
          value: %("seven"),
          add_comma: false,
        ),
        line(
          type: :noop,
          indentation_level: 0,
          value: %(]),
          add_comma: false,
          collection_bookend: :close,
          complete_bookend: :close,
        ),
      ]

      line_tree_with_elisions = with_configuration(diff_elision_threshold: 3) do
        described_class.call(lines)
      end

      expect(line_tree_with_elisions).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          value: %([),
          add_comma: false,
          children: [],
          elided?: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          value: %("one"),
          add_comma: true,
          children: [],
          elided?: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          value: %("two"),
          add_comma: true,
          children: [],
          elided?: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          value: %("three"),
          add_comma: true,
          children: [],
          elided?: false,
        ),
        an_object_having_attributes(
          type: :delete,
          indentation_level: 1,
          value: %("four"),
          add_comma: true,
          children: [],
          elided?: false,
        ),
        an_object_having_attributes(
          type: :insert,
          indentation_level: 1,
          value: %("FOUR"),
          add_comma: true,
          children: [],
          elided?: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          value: %("five"),
          add_comma: true,
          children: [],
          elided?: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          value: %("six"),
          add_comma: true,
          children: [],
          elided?: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          value: %("seven"),
          add_comma: false,
          children: [],
          elided?: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          value: %(]),
          add_comma: false,
          children: [],
          elided?: false,
        ),
      ])
    end
  end

  context "and there is a sequence of noops that spans more than some threshold of lines" do
    context "and padding around the non-noops is not used to determine that sequence" do
      context "and the tree is one-dimensional" do
        context "and the line tree is just noops" do
          it "doesn't elide anything" do
            # Diff:
            #
            #   [
            #     "alpha",
            #     "beta",
            #     [
            #       "proton",
            #       [
            #         "electron",
            #         "photon",
            #         "gluon"
            #       ],
            #       "neutron"
            #     ],
            #     "digamma",
            #     "waw",
            #     "omega"
            #   ]

            lines = [
              line(
                type: :noop,
                indentation_level: 0,
                value: %([),
                collection_bookend: :open,
                complete_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %([),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("["),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("electron"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("photon"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("gluon"),
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("]"),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("neutron"),
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("digamma"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
              ),
              line(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                collection_bookend: :close,
                complete_bookend: :close,
              ),
            ]

            line_tree_with_elisions =
              with_configuration(diff_elision_threshold: 5) do
                described_class.call(lines)
              end

            expect(line_tree_with_elisions).to match([
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %("["),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 3,
                value: %("electron"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 3,
                value: %("photon"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 3,
                value: %("gluon"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %("]"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %("neutron"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("digamma"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                add_comma: false,
                children: [],
                elided?: false,
              ),
            ])
          end
        end

        context "and the line tree is more than just noops" do
          it "represents the sequence as an elision" do
            # Diff:
            #
            #   [
            #     "one",
            #     "two",
            #     "three",
            #     "four",
            # -   "five",
            # +   "FIVE",
            #     "six",
            #     "seven",
            #     "eight",
            #     "nine",
            #   ]

            lines = [
              line(
                type: :noop,
                indentation_level: 0,
                value: %([),
                collection_bookend: :open,
                complete_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("one"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("two"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("three"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("four"),
                add_comma: true,
              ),
              line(
                type: :delete,
                indentation_level: 1,
                value: %("five"),
                add_comma: true,
              ),
              line(
                type: :insert,
                indentation_level: 1,
                value: %("FIVE"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("six"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("seven"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("eight"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("nine"),
              ),
              line(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                collection_bookend: :close,
                complete_bookend: :close,
              ),
            ]

            line_tree_with_elisions =
              with_configuration(diff_elision_threshold: 3) do
                described_class.call(lines)
              end

            expect(line_tree_with_elisions).to match([
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :elision,
                indentation_level: 1,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("four"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                ],
                elided?: true,
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: %("five"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :insert,
                indentation_level: 1,
                value: %("FIVE"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                indentation_level: 1,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("six"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("eight"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("nine"),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                ],
                elided?: true,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                add_comma: false,
                children: [],
                elided?: false,
              ),
            ])
          end
        end
      end

      context "and the tree is multi-dimensional" do
        context "and the sequence of noops does not cross indentation level boundaries" do
          it "represents the smallest portion within the sequence as an elision (descending into sub-structures if necessary) to fit the whole sequence under the threshold" do
            # Diff:
            #
            #   [
            #     "alpha",
            #     "beta",
            #     [
            #       "proton",
            #       [
            #         "electron",
            #         "photon",
            #         "gluon"
            #       ],
            #       "neutron"
            #     ],
            # -   "digamma",
            # +   "waw",
            #     "omega"
            #   ]

            lines = [
              line(
                type: :noop,
                indentation_level: 0,
                value: %([),
                collection_bookend: :open,
                complete_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %([),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("["),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("electron"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("photon"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("gluon"),
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("]"),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("neutron"),
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :delete,
                indentation_level: 1,
                value: %("digamma"),
                add_comma: true,
              ),
              line(
                type: :insert,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
              ),
              line(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                collection_bookend: :close,
                complete_bookend: :close,
              ),
            ]

            line_tree_with_elisions =
              with_configuration(diff_elision_threshold: 5) do
                described_class.call(lines)
              end

            expect(line_tree_with_elisions).to match([
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :elision,
                indentation_level: 2,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("proton"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("["),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 3,
                    value: %("electron"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 3,
                    value: %("photon"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 3,
                    value: %("gluon"),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("]"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("neutron"),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                ],
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: %("digamma"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :insert,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                add_comma: false,
                children: [],
                elided?: false,
              ),
            ])
          end
        end

        context "and the sequence of noops crosses indentation level boundaries" do
          context "assuming that, after the lines that fit completely inside those boundaries are elided, the sequence of noops is below the threshold" do
            it "only elides lines which fit completely inside the selected sections" do
              # Diff:
              #
              #   [
              #     "alpha",
              #     [
              #       "zeta",
              #       "eta"
              #     ],
              #     "beta",
              #     [
              #       "proton",
              #       "electron",
              #       [
              # -       "red",
              # +       "blue",
              #         "green"
              #       ],
              #       "neutron",
              #       "charm",
              #       "up",
              #       "down"
              #     ],
              #     "waw",
              #     "omega"
              #   ]

              lines = [
                line(
                  type: :noop,
                  indentation_level: 0,
                  value: %([),
                  complete_bookend: :open,
                  collection_bookend: :open,
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("alpha"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %([),
                  collection_bookend: :open,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("zeta"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("eta"),
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %(]),
                  add_comma: true,
                  collection_bookend: :close,
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("beta"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %([),
                  collection_bookend: :open,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("proton"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("electron"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %([),
                  collection_bookend: :open,
                ),
                line(
                  type: :delete,
                  indentation_level: 3,
                  value: %("red"),
                  add_comma: true,
                ),
                line(
                  type: :insert,
                  indentation_level: 3,
                  value: %("blue"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 3,
                  value: %("green"),
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %(]),
                  add_comma: true,
                  collection_bookend: :close,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("neutron"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("charm"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("up"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("down"),
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %(]),
                  add_comma: true,
                  collection_bookend: :close,
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("waw"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("omega"),
                ),
                line(
                  type: :noop,
                  indentation_level: 0,
                  value: %(]),
                  collection_bookend: :close,
                  complete_bookend: :close,
                ),
              ]

              line_tree_with_elisions =
                with_configuration(diff_elision_threshold: 5) do
                  described_class.call(lines)
                end

              expect(line_tree_with_elisions).to match([
                an_object_having_attributes(
                  type: :noop,
                  indentation_level: 0,
                  value: %([),
                  add_comma: false,
                  children: [],
                  elided?: false,
                ),
                an_object_having_attributes(
                  type: :elision,
                  indentation_level: 1,
                  children: [
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true,
                      children: [],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      add_comma: false,
                      children: [],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %("zeta"),
                      add_comma: true,
                      children: [],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %("eta"),
                      add_comma: false,
                      children: [],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      add_comma: true,
                      children: [],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %("beta"),
                      add_comma: true,
                      children: [],
                      elided?: true,
                    ),
                  ],
                  elided?: true,
                ),
                an_object_having_attributes(
                  type: :noop,
                  indentation_level: 1,
                  value: %([),
                  add_comma: false,
                  children: [],
                  elided?: false,
                ),
                an_object_having_attributes(
                  type: :elision,
                  indentation_level: 2,
                  children: [
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %("proton"),
                      add_comma: true,
                      children: [],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %("electron"),
                      add_comma: true,
                      children: [],
                      elided?: true,
                    ),
                  ],
                  elided?: true,
                ),
                an_object_having_attributes(
                  type: :noop,
                  indentation_level: 2,
                  value: %([),
                  add_comma: false,
                  children: [],
                  elided?: false,
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  value: %("red"),
                  add_comma: true,
                  children: [],
                  elided?: false,
                ),
                an_object_having_attributes(
                  type: :insert,
                  indentation_level: 3,
                  value: %("blue"),
                  add_comma: true,
                  children: [],
                  elided?: false,
                ),
                an_object_having_attributes(
                  type: :elision,
                  indentation_level: 3,
                  children: [
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 3,
                      value: %("green"),
                      add_comma: false,
                      children: [],
                      elided?: true,
                    ),
                  ],
                  elided?: true,
                ),
                an_object_having_attributes(
                  type: :noop,
                  indentation_level: 2,
                  value: %(]),
                  add_comma: true,
                  children: [],
                  elided?: false,
                ),
                an_object_having_attributes(
                  type: :elision,
                  indentation_level: 2,
                  children: [
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %("neutron"),
                      add_comma: true,
                      children: [],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %("charm"),
                      add_comma: true,
                      children: [],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %("up"),
                      add_comma: true,
                      children: [],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %("down"),
                      add_comma: false,
                      children: [],
                      elided?: true,
                    ),
                  ],
                  elided?: true,
                ),
                an_object_having_attributes(
                  type: :noop,
                  indentation_level: 1,
                  value: %(]),
                  add_comma: true,
                  children: [],
                  elided?: false,
                ),
                an_object_having_attributes(
                  type: :elision,
                  indentation_level: 1,
                  children: [
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %("waw"),
                      add_comma: true,
                      children: [],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %("omega"),
                      add_comma: false,
                      children: [],
                      elided?: true,
                    ),
                  ],
                  elided?: true,
                ),
                an_object_having_attributes(
                  type: :noop,
                  indentation_level: 0,
                  value: %(]),
                  add_comma: false,
                  children: [],
                  elided?: false,
                ),
              ])
            end
          end

          context "when, after the lines that fit completely inside those boundaries are elided, the sequence of noops is still above the threshold" do
            it "elides the lines as much as possible" do
              # Before eliding:
              #
              #   [
              #     "alpha",
              #     [
              #       "beta",
              #       "gamma"
              #     ],
              #     "pi",
              #     [
              #       [
              # -       "red",
              # +       "blue"
              #       ]
              #     ]
              #   ]

              lines = [
                line(
                  type: :noop,
                  indentation_level: 0,
                  value: %([),
                  complete_bookend: :open,
                  collection_bookend: :open,
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("alpha"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %([),
                  collection_bookend: :open,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("beta"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %("gamma"),
                  add_comma: false,
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %(]),
                  collection_bookend: :close,
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %("pi"),
                  add_comma: true,
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %([),
                  collection_bookend: :open,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %([),
                  collection_bookend: :open,
                ),
                line(
                  type: :delete,
                  indentation_level: 3,
                  value: %("red"),
                  add_comma: true,
                ),
                line(
                  type: :insert,
                  indentation_level: 3,
                  value: %("blue"),
                  add_comma: false,
                ),
                line(
                  type: :noop,
                  indentation_level: 2,
                  value: %(]),
                  collection_bookend: :close,
                ),
                line(
                  type: :noop,
                  indentation_level: 1,
                  value: %(]),
                  collection_bookend: :close,
                ),
                line(
                  type: :noop,
                  indentation_level: 0,
                  value: %(]),
                  collection_bookend: :close,
                ),
              ]

              line_tree_with_elisions =
                with_configuration(diff_elision_threshold: 5) do
                  described_class.call(lines)
                end

              # binding.pry

              # After eliding:
              #
              #   [
              #     # ...
              #     [
              #       [
              # -       "red",
              # +       "blue"
              #       ]
              #     ]
              #   ]

              expect(line_tree_with_elisions).to match([
                an_object_having_attributes(
                  type: :noop,
                  indentation_level: 0,
                  value: %([),
                  complete_bookend: :open,
                  collection_bookend: :open,
                  children: [],
                  elided: false,
                ),
                an_object_having_attributes(
                  type: :elision,
                  indentation_level: 1,
                  children: [
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true,
                      children: [],
                      elided: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      collection_bookend: :open,
                      children: [],
                      elided: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %("beta"),
                      add_comma: true,
                      children: [],
                      elided: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %("gamma"),
                      add_comma: false,
                      children: [],
                      elided: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      collection_bookend: :close,
                      children: [],
                      elided: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %("pi"),
                      add_comma: true,
                      children: [],
                      elided: true,
                    ),
                  ]
                ),
                an_object_having_attributes(
                  type: :noop,
                  indentation_level: 1,
                  value: %([),
                  collection_bookend: :open,
                  children: [],
                  elided: false,
                ),
                an_object_having_attributes(
                  type: :noop,
                  indentation_level: 2,
                  value: %([),
                  collection_bookend: :open,
                  children: [],
                  elided: false,
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  value: %("red"),
                  add_comma: true,
                  children: [],
                  elided: false,
                ),
                an_object_having_attributes(
                  type: :insert,
                  indentation_level: 3,
                  value: %("blue"),
                  add_comma: false,
                  children: [],
                  elided: false,
                ),
                an_object_having_attributes(
                  type: :noop,
                  indentation_level: 2,
                  value: %(]),
                  collection_bookend: :close,
                  children: [],
                  elided: false,
                ),
                an_object_having_attributes(
                  type: :noop,
                  indentation_level: 1,
                  value: %(]),
                  collection_bookend: :close,
                  children: [],
                  elided: false,
                ),
                an_object_having_attributes(
                  type: :noop,
                  indentation_level: 0,
                  value: %(]),
                  collection_bookend: :close,
                  children: [],
                  elided: false,
                ),
              ])
            end
          end
        end
      end
    end

    context "and padding around the non-noops is used to determine that sequence" do
      context "and the tree is one-dimensional" do
        context "and the line tree is just noops" do
          it "doesn't elide anything" do
            # Diff:
            #
            #   [
            #     "alpha",
            #     "beta",
            #     [
            #       "proton",
            #       [
            #         "electron",
            #         "photon",
            #         "gluon"
            #       ],
            #       "neutron"
            #     ],
            #     "digamma",
            #     "waw",
            #     "omega"
            #   ]

            lines = [
              line(
                type: :noop,
                indentation_level: 0,
                value: %([),
                collection_bookend: :open,
                complete_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %([),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("["),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("electron"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("photon"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("gluon"),
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("]"),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("neutron"),
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("digamma"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
              ),
              line(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                collection_bookend: :close,
                complete_bookend: :close,
              ),
            ]

            line_tree_with_elisions = with_configuration(
              diff_elision_threshold: 5,
              diff_elision_padding: 1,
            ) do
              described_class.call(lines)
            end

            expect(line_tree_with_elisions).to match([
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %("["),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 3,
                value: %("electron"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 3,
                value: %("photon"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 3,
                value: %("gluon"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %("]"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %("neutron"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("digamma"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                add_comma: false,
                children: [],
                elided?: false,
              ),
            ])
          end
        end

        context "and the line tree is more than just noops" do
          it "represents the sequence as an elision" do
            # Diff:
            #
            #   [
            #     "one",
            #     "two",
            #     "three",
            #     "four",
            # -   "five",
            # +   "FIVE",
            #     "six",
            #     "seven",
            #     "eight",
            #     "nine",
            #   ]

            lines = [
              line(
                type: :noop,
                indentation_level: 0,
                value: %([),
                collection_bookend: :open,
                complete_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("one"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("two"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("three"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("four"),
                add_comma: true,
              ),
              line(
                type: :delete,
                indentation_level: 1,
                value: %("five"),
                add_comma: true,
              ),
              line(
                type: :insert,
                indentation_level: 1,
                value: %("FIVE"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("six"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("seven"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("eight"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("nine"),
              ),
              line(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                collection_bookend: :close,
                complete_bookend: :close,
              ),
            ]

            line_tree_with_elisions = with_configuration(
              diff_elision_threshold: 2,
              diff_elision_padding: 1,
            ) do
              described_class.call(lines)
            end

            expect(line_tree_with_elisions).to match([
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :elision,
                indentation_level: 1,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                ],
                elided?: true,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("four"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: %("five"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :insert,
                indentation_level: 1,
                value: %("FIVE"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("six"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                indentation_level: 1,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("eight"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("nine"),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                ],
                elided?: true,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                add_comma: false,
                children: [],
                elided?: false,
              ),
            ])
          end
        end
      end

      context "and the tree is multi-dimensional" do
        context "and the sequence of noops does not cross indentation level boundaries" do
          it "represents the smallest portion within the sequence as an elision (descending into sub-structures if necessary) to fit the whole sequence under the threshold" do
            # Diff:
            #
            #   [
            #     "alpha",
            #     "beta",
            #     [
            #       "proton",
            #       [
            #         "electron",
            #         "photon",
            #         "gluon"
            #       ],
            #       "neutron"
            #     ],
            # -   "digamma",
            # +   "waw",
            #     "omega"
            #   ]

            lines = [
              line(
                type: :noop,
                indentation_level: 0,
                value: %([),
                collection_bookend: :open,
                complete_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %([),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("["),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("electron"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("photon"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("gluon"),
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("]"),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("neutron"),
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :delete,
                indentation_level: 1,
                value: %("digamma"),
                add_comma: true,
              ),
              line(
                type: :insert,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
              ),
              line(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                collection_bookend: :close,
                complete_bookend: :close,
              ),
            ]

            line_tree_with_elisions = with_configuration(
              diff_elision_threshold: 5,
              diff_elision_padding: 1
            ) do
              described_class.call(lines)
            end

            expect(line_tree_with_elisions).to match([
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :elision,
                indentation_level: 2,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("proton"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("["),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 3,
                    value: %("electron"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 3,
                    value: %("photon"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 3,
                    value: %("gluon"),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("]"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("neutron"),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                ],
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: %("digamma"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :insert,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                add_comma: false,
                children: [],
                elided?: false,
              ),
            ])
          end
        end

        context "and the sequence of noops crosses indentation level boundaries" do
          it "only elides lines which fit completely inside the selected sections" do
            # Input diff:
            #
            #   [
            #     "alpha",
            #     [
            #       "zeta",
            #       "eta"
            #     ],
            #     "beta",
            #     [
            #       "proton",
            #       "electron",
            #       [
            # -       "red",
            # +       "blue",
            #         "green"
            #       ],
            #       "neutron",
            #       "charm",
            #       "up",
            #       "down"
            #     ],
            #     "waw",
            #     "omega"
            #   ]

            lines = [
              line(
                type: :noop,
                indentation_level: 0,
                value: %([),
                complete_bookend: :open,
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %([),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("zeta"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("eta"),
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %([),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("electron"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %([),
                collection_bookend: :open,
              ),
              line(
                type: :delete,
                indentation_level: 3,
                value: %("red"),
                add_comma: true,
              ),
              line(
                type: :insert,
                indentation_level: 3,
                value: %("blue"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("green"),
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %(]),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("neutron"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("charm"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("up"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("down"),
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
              ),
              line(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                collection_bookend: :close,
                complete_bookend: :close,
              ),
            ]

            line_tree_with_elisions = with_configuration(
              diff_elision_threshold: 5,
              diff_elision_padding: 1
            ) do
              described_class.call(lines)
            end

            # Output diff:
            #
            #   [
            #     # ...
            #     [
            #       # ...
            #       [
            # -       "red",
            # +       "blue",
            #         "green"
            #       ],
            #       # ...
            #     ],
            #     "waw",
            #     "omega"
            #   ]

            expect(line_tree_with_elisions).to match([
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :elision,
                indentation_level: 1,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("alpha"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %([),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("zeta"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("eta"),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %(]),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("beta"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                ],
                elided?: true,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :elision,
                indentation_level: 2,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("proton"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("electron"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                ],
                elided?: true,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 3,
                value: %("red"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :insert,
                indentation_level: 3,
                value: %("blue"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 3,
                value: %("green"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %(]),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :elision,
                indentation_level: 2,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("neutron"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("charm"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("up"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("down"),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                ],
                elided?: true,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                add_comma: false,
                children: [],
                elided?: false,
              ),
            ])
          end
        end
      end
    end
  end

  def line(**args)
    SuperDiff::Line.new(**args)
  end
end
