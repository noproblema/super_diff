require "spec_helper"

RSpec.describe "Integration with RSpec's #eq matcher", type: :integration do
  context "when comparing two different integers" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = %|expect(1).to eq(42)|
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: snippet,
          expectation: proc {
            line do
              plain "Expected "
              beta %|1|
              plain " to eq "
              alpha %|42|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = %|expect(42).not_to eq(42)|
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: snippet,
          expectation: proc {
            line do
              plain "Expected "
              beta %|42|
              plain " not to eq "
              alpha %|42|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two different symbols" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = %|expect(:bar).to eq(:foo)|
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: snippet,
          expectation: proc {
            line do
              plain "Expected "
              beta %|:bar|
              plain " to eq "
              alpha %|:foo|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = %|expect(:foo).not_to eq(:foo)|
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: snippet,
          expectation: proc {
            line do
              plain "Expected "
              beta %|:foo|
              plain " not to eq "
              alpha %|:foo|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two single-line strings" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = %|expect("Jennifer").to eq("Marty")|
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect("Jennifer").to eq("Marty")|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|"Jennifer"|
              plain " to eq "
              alpha %|"Marty"|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = %|expect("Jennifer").not_to eq("Jennifer")|
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect("Jennifer").not_to eq("Jennifer")|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|"Jennifer"|
              plain " not to eq "
              alpha %|"Jennifer"|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two different Time instances" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~RUBY
          expected = Time.utc(2011, 12, 13, 14, 15, 16)
          actual = Time.utc(2011, 12, 13, 14, 15, 16, 500_000)
          expect(expected).to eq(actual)
        RUBY
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(expected).to eq(actual)|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|2011-12-13 14:15:16.000 UTC +00:00 (Time)|
              plain " to eq "
              alpha %|2011-12-13 14:15:16.500 UTC +00:00 (Time)|
              plain "."
            end
          },
          diff: proc {
            plain_line "  #<Time {"
            plain_line "    year: 2011,"
            plain_line "    month: 12,"
            plain_line "    day: 13,"
            plain_line "    hour: 14,"
            plain_line "    min: 15,"
            plain_line "    sec: 16,"
            alpha_line "-   nsec: 500000000,"
            beta_line  "+   nsec: 0,"
            plain_line "    zone: \"UTC\","
            plain_line "    gmt_offset: 0"
            plain_line "  }>"
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~RUBY
          time = Time.utc(2011, 12, 13, 14, 15, 16)
          expect(time).not_to eq(time)
        RUBY
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(time).not_to eq(time)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain " Expected "
              beta %|2011-12-13 14:15:16.000 UTC +00:00 (Time)|
            end

            line do
              plain "not to eq "
              alpha %|2011-12-13 14:15:16.000 UTC +00:00 (Time)|
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing a single-line string with a multi-line string" do
    it "produces the correct failure message" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = "Something entirely different"
          actual = "This is a line\\nAnd that's another line\\n"
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to eq(expected)|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|"This is a line\\nAnd that's another line\\n"|
              plain " to eq "
              alpha %|"Something entirely different"|
              plain "."
            end
          },
          diff: proc {
            alpha_line %|- Something entirely different|
            beta_line  %|+ This is a line\\n|
            beta_line  %|+ And that's another line\\n|
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing a multi-line string with a single-line string" do
    it "produces the correct failure message" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = "This is a line\\nAnd that's another line\\n"
          actual = "Something entirely different"
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to eq(expected)|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|"Something entirely different"|
              plain " to eq "
              alpha %|"This is a line\\nAnd that's another line\\n"|
              plain "."
            end
          },
          diff: proc {
            alpha_line %|- This is a line\\n|
            alpha_line %|- And that's another line\\n|
            beta_line  %|+ Something entirely different|
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two multi-line strings" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = "This is a line\\nAnd that's a line\\nAnd there's a line too\\n"
          actual = "This is a line\\nSomething completely different\\nAnd there's a line too\\n"
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to eq(expected)|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|"This is a line\\nSomething completely different\\nAnd there's a line too\\n"|
            end

            line do
              plain "   to eq "
              alpha %|"This is a line\\nAnd that's a line\\nAnd there's a line too\\n"|
            end
          },
          diff: proc {
            plain_line %|  This is a line\\n|
            alpha_line %|- And that's a line\\n|
            beta_line  %|+ Something completely different\\n|
            plain_line %|  And there's a line too\\n|
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          string = "This is a line\\nAnd that's a line\\nAnd there's a line too\\n"
          expect(string).not_to eq(string)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(string).not_to eq(string)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain " Expected "
              beta %|"This is a line\\nAnd that's a line\\nAnd there's a line too\\n"|
            end

            line do
              plain "not to eq "
              alpha %|"This is a line\\nAnd that's a line\\nAnd there's a line too\\n"|
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two arrays with other data structures inside" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST
          expected = [
            [
              :h1,
              [:span, [:text, "Hello world"]],
              {
                class: "header",
                data: {
                  "sticky" => true,
                  person: SuperDiff::Test::Person.new(name: "Marty", age: 60)
                }
              }
            ]
          ]
          actual = [
            [
              :h2,
              [:span, [:text, "Goodbye world"]],
              {
                id: "hero",
                class: "header",
                data: {
                  "sticky" => false,
                  role: "deprecated",
                  person: SuperDiff::Test::Person.new(name: "Doc", age: 60)
                }
              }
            ],
            :br
          ]
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to eq(expected)|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|[[:h2, [:span, [:text, "Goodbye world"]], { id: "hero", class: "header", data: { "sticky" => false, :role => "deprecated", :person => #<SuperDiff::Test::Person name: "Doc", age: 60> } }], :br]|
            end

            line do
              plain "   to eq "
              alpha %|[[:h1, [:span, [:text, "Hello world"]], { class: "header", data: { "sticky" => true, :person => #<SuperDiff::Test::Person name: "Marty", age: 60> } }]]|
            end
          },
          diff: proc {
            plain_line %|  [|
            plain_line %|    [|
            alpha_line %|-     :h1,|
            beta_line  %|+     :h2,|
            plain_line %|      [|
            plain_line %|        :span,|
            plain_line %|        [|
            plain_line %|          :text,|
            alpha_line %|-         "Hello world"|
            beta_line  %|+         "Goodbye world"|
            plain_line %|        ]|
            plain_line %|      ],|
            plain_line %|      {|
            beta_line  %|+       id: "hero",|
            plain_line %|        class: "header",|
            plain_line %|        data: {|
            alpha_line %|-         "sticky" => true,|
            beta_line  %|+         "sticky" => false,|
            beta_line  %|+         :role => "deprecated",|
            plain_line %|          :person => #<SuperDiff::Test::Person {|
            alpha_line %|-           name: "Marty",|
            beta_line  %|+           name: "Doc",|
            plain_line %|            age: 60|
            plain_line %|          }>|
            plain_line %|        }|
            plain_line %|      }|
            plain_line %|    ],|
            beta_line  %|+   :br|
            plain_line %|  ]|
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST
          value = [
            [
              :h1,
              [:span, [:text, "Hello world"]],
              {
                class: "header",
                data: {
                  "sticky" => true,
                  person: SuperDiff::Test::Person.new(name: "Marty", age: 60)
                }
              }
            ]
          ]
          expect(value).not_to eq(value)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(value).not_to eq(value)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain " Expected "
              beta %|[[:h1, [:span, [:text, "Hello world"]], { class: "header", data: { "sticky" => true, :person => #<SuperDiff::Test::Person name: "Marty", age: 60> } }]]|
            end

            line do
              plain "not to eq "
              alpha %|[[:h1, [:span, [:text, "Hello world"]], { class: "header", data: { "sticky" => true, :person => #<SuperDiff::Test::Person name: "Marty", age: 60> } }]]|
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two hashes with other data structures inside" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = {
            customer: {
              person: SuperDiff::Test::Person.new(name: "Marty McFly", age: 17),
              shipping_address: {
                line_1: "123 Main St.",
                city: "Hill Valley",
                state: "CA",
                zip: "90382"
              }
            },
            items: [
              {
                name: "Fender Stratocaster",
                cost: 100_000,
                options: ["red", "blue", "green"]
              },
              { name: "Chevy 4x4" }
            ]
          }
          actual = {
            customer: {
              person: SuperDiff::Test::Person.new(name: "Marty McFly, Jr.", age: 17),
              shipping_address: {
                line_1: "456 Ponderosa Ct.",
                city: "Hill Valley",
                state: "CA",
                zip: "90382"
              }
            },
            items: [
              {
                name: "Fender Stratocaster",
                cost: 100_000,
                options: ["red", "blue", "green"]
              },
              { name: "Mattel Hoverboard" }
            ]
          }
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to eq(expected)|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|{ customer: { person: #<SuperDiff::Test::Person name: "Marty McFly, Jr.", age: 17>, shipping_address: { line_1: "456 Ponderosa Ct.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Mattel Hoverboard" }] }|
            end

            line do
              plain "   to eq "
              alpha %|{ customer: { person: #<SuperDiff::Test::Person name: "Marty McFly", age: 17>, shipping_address: { line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Chevy 4x4" }] }|
            end
          },
          diff: proc {
            plain_line %|  {|
            plain_line %|    customer: {|
            plain_line %|      person: #<SuperDiff::Test::Person {|
            alpha_line %|-       name: "Marty McFly",|
            beta_line  %|+       name: "Marty McFly, Jr.",|
            plain_line %|        age: 17|
            plain_line %|      }>,|
            plain_line %|      shipping_address: {|
            alpha_line %|-       line_1: "123 Main St.",|
            beta_line  %|+       line_1: "456 Ponderosa Ct.",|
            plain_line %|        city: "Hill Valley",|
            plain_line %|        state: "CA",|
            plain_line %|        zip: "90382"|
            plain_line %|      }|
            plain_line %|    },|
            plain_line %|    items: [|
            plain_line %|      {|
            plain_line %|        name: "Fender Stratocaster",|
            plain_line %|        cost: 100000,|
            plain_line %|        options: [|
            plain_line %|          "red",|
            plain_line %|          "blue",|
            plain_line %|          "green"|
            plain_line %|        ]|
            plain_line %|      },|
            plain_line %|      {|
            alpha_line %|-       name: "Chevy 4x4"|
            beta_line  %|+       name: "Mattel Hoverboard"|
            plain_line %|      }|
            plain_line %|    ]|
            plain_line %|  }|
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          value = {
            customer: {
              person: SuperDiff::Test::Person.new(name: "Marty McFly", age: 17),
              shipping_address: {
                line_1: "123 Main St.",
                city: "Hill Valley",
                state: "CA",
                zip: "90382"
              }
            },
            items: [
              {
                name: "Fender Stratocaster",
                cost: 100_000,
                options: ["red", "blue", "green"]
              },
              { name: "Chevy 4x4" }
            ]
          }
          expect(value).not_to eq(value)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(value).not_to eq(value)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain " Expected "
              beta %|{ customer: { person: #<SuperDiff::Test::Person name: "Marty McFly", age: 17>, shipping_address: { line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Chevy 4x4" }] }|
            end

            line do
              plain "not to eq "
              alpha %|{ customer: { person: #<SuperDiff::Test::Person name: "Marty McFly", age: 17>, shipping_address: { line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Chevy 4x4" }] }|
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two different kinds of custom objects" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = SuperDiff::Test::Person.new(
            name: "Marty",
            age: 31,
          )
          actual = SuperDiff::Test::Customer.new(
            name: "Doc",
            shipping_address: :some_shipping_address,
            phone: "1234567890",
          )
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to eq(expected)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "Expected "
              beta %|#<SuperDiff::Test::Customer name: "Doc", shipping_address: :some_shipping_address, phone: "1234567890">|
            end

            line do
              plain "   to eq "
              alpha %|#<SuperDiff::Test::Person name: "Marty", age: 31>|
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          value = SuperDiff::Test::Person.new(
            name: "Marty",
            age: 31,
          )
          expect(value).not_to eq(value)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(value).not_to eq(value)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain " Expected "
              beta %|#<SuperDiff::Test::Person name: "Marty", age: 31>|
            end

            line do
              plain "not to eq "
              alpha %|#<SuperDiff::Test::Person name: "Marty", age: 31>|
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two different kinds of non-custom objects" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = SuperDiff::Test::Item.new(
            name: "camera",
            quantity: 3,
          )
          actual = SuperDiff::Test::Player.new(
            handle: "mcmire",
            character: "Jon",
            inventory: ["sword"],
            shields: 11.4,
            health: 4,
            ultimate: true,
          )
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to eq(expected)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "Expected "
              beta %|#<SuperDiff::Test::Player @character="Jon", @handle="mcmire", @health=4, @inventory=["sword"], @shields=11.4, @ultimate=true>|
            end

            line do
              plain "   to eq "
              alpha %|#<SuperDiff::Test::Item @name="camera", @quantity=3>|
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled).
          removing_object_ids
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          value = SuperDiff::Test::Item.new(
            name: "camera",
            quantity: 3,
          )
          expect(value).not_to eq(value)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(value).not_to eq(value)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain " Expected "
              beta %|#<SuperDiff::Test::Item @name="camera", @quantity=3>|
            end

            line do
              plain "not to eq "
              alpha %|#<SuperDiff::Test::Item @name="camera", @quantity=3>|
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled).
          removing_object_ids
      end
    end
  end

  context "when comparing two data structures where one contains an empty array" do
    it "formats the array correctly in the diff" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = { foo: nil }
          actual = { foo: [] }
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to eq(expected)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "Expected "
              beta %|{ foo: [] }|
              plain " to eq "
              alpha %|{ foo: nil }|
              plain "."
            end
          },
          diff: proc {
            plain_line %|  {|
            alpha_line %|-   foo: nil|
            beta_line  %|+   foo: []|
            plain_line %|  }|
          }
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two data structures where one contains an empty hash" do
    it "formats the hash correctly in the diff" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = { foo: nil }
          actual = { foo: {} }
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to eq(expected)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "Expected "
              beta %|{ foo: {} }|
              plain " to eq "
              alpha %|{ foo: nil }|
              plain "."
            end
          },
          diff: proc {
            plain_line %|  {|
            alpha_line %|-   foo: nil|
            beta_line  %|+   foo: {}|
            plain_line %|  }|
          }
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two data structures where one contains an empty object" do
    it "formats the object correctly in the diff" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = { foo: nil }
          actual = { foo: SuperDiff::Test::EmptyClass.new }
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to eq(expected)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "Expected "
              beta %|{ foo: #<SuperDiff::Test::EmptyClass> }|
              plain " to eq "
              alpha %|{ foo: nil }|
              plain "."
            end
          },
          diff: proc {
            plain_line %|  {|
            alpha_line %|-   foo: nil|
            beta_line  %|+   foo: #<SuperDiff::Test::EmptyClass>|
            plain_line %|  }|
          }
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled).
          removing_object_ids
      end
    end
  end

  context "when comparing two different data structures which are mostly the same aside from a few differences" do
    context "if diff_elision_enabled is set to true" do
      context "and there is only one level to consider" do
        it "elides the samenesses" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expected = [
                "Afghanistan",
                "Aland Islands",
                "Albania",
                "Algeria",
                "American Samoa",
                "Andorra",
                "Angola",
                "Antarctica",
                "Antigua And Barbuda",
                "Argentina",
                "Armenia",
                "Aruba",
                "Australia"
              ]
              actual = [
                "Afghanistan",
                "Aland Islands",
                "Albania",
                "Algeria",
                "American Samoa",
                "Andorra",
                "Anguilla",
                "Antarctica",
                "Antigua And Barbuda",
                "Argentina",
                "Armenia",
                "Aruba",
                "Australia"
              ]
              expect(actual).to eq(expected)
            TEST
            program = make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
              configuration: {
                diff_elision_enabled: true,
                diff_elision_threshold: 2,
                diff_elision_padding: 3,
              },
            )

            expected_output = build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect(actual).to eq(expected)|,
              newline_before_expectation: true,
              expectation: proc {
                line do
                  plain "Expected "
                  # rubocop:disable Layout/LineLength
                  beta %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
                  # rubocop:enable Layout/LineLength
                end

                line do
                  plain "   to eq "
                  # rubocop:disable Layout/LineLength
                  alpha %|["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia"]|
                  # rubocop:enable Layout/LineLength
                end
              },
              diff: proc {
                plain_line %|  [|
                gamma_line %|    # ...|
                plain_line %|    "Algeria",|
                plain_line %|    "American Samoa",|
                plain_line %|    "Andorra",|
                alpha_line %|-   "Angola",|
                beta_line  %|+   "Anguilla",|
                plain_line %|    "Antarctica",|
                plain_line %|    "Antigua And Barbuda",|
                plain_line %|    "Argentina",|
                gamma_line %|    # ...|
                plain_line %|  ]|
              },
            )

            expect(program).
              to produce_output_when_run(expected_output).
              in_color(color_enabled)
          end
        end
      end

      context "and there are multiple levels to consider" do
        # TODO see if we can correct the order of the keys here so it's not
        # totally weird
        it "elides the samenesses" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expected = [
                {
                  "user_id": "18949452",
                  "user": {
                    "id": 18949452,
                    "name": "Financial Times",
                    "screen_name": "FT",
                    "location": "London",
                    "entities": {
                      "url": {
                        "urls": [
                          {
                            "url": "http://t.co/dnhLQpd9BY",
                            "expanded_url": "http://www.ft.com/",
                            "display_url": "ft.com",
                            "indices": [
                              0,
                              22
                            ]
                          }
                        ]
                      },
                      "description": {
                        "urls": [
                          {
                            "url": "https://t.co/5BsmLs9y1Z",
                            "expanded_url": "http://FT.com",
                            "indices": [
                              65,
                              88
                            ]
                          }
                        ]
                      }
                    },
                    "listed_count": 37009,
                    "created_at": "Tue Jan 13 19:28:24 +0000 2009",
                    "favourites_count": 38,
                    "utc_offset": nil,
                    "time_zone": nil,
                    "geo_enabled": false,
                    "verified": true,
                    "statuses_count": 273860,
                    "media_count": 51044,
                    "contributors_enabled": false,
                    "is_translator": false,
                    "is_translation_enabled": false,
                    "profile_background_color": "FFF1E0",
                    "profile_background_image_url_https": "https://abs.twimg.com/images/themes/theme1/bg.png",
                    "profile_background_tile": false,
                    "profile_image_url": "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                    "profile_image_url_https": "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                    "profile_banner_url": "https://pbs.twimg.com/profile_banners/18949452/1581526592",
                    "profile_image_extensions": {
                      "mediaStats": {
                        "r": {
                          "missing": nil
                        },
                        "ttl": -1
                      }
                    },
                    "profile_banner_extensions": {},
                    "blocking": false,
                    "blocked_by": false,
                    "want_retweets": false,
                    "advertiser_account_type": "none",
                    "advertiser_account_service_levels": [],
                    "profile_interstitial_type": "",
                    "business_profile_state": "none",
                    "translator_type": "none",
                    "followed_by": false,
                    "ext": {
                      "highlightedLabel": {
                        "ttl": -1
                      }
                    },
                    "require_some_consent": false
                  },
                  "token": "117"
                }
              ]
              actual = [
                {
                  "user_id": "18949452",
                  "user": {
                    "id": 18949452,
                    "name": "Financial Times",
                    "screen_name": "FT",
                    "location": "London",
                    "url": "http://t.co/dnhLQpd9BY",
                    "entities": {
                      "url": {
                        "urls": [
                          {
                            "url": "http://t.co/dnhLQpd9BY",
                            "expanded_url": "http://www.ft.com/",
                            "display_url": "ft.com",
                            "indices": [
                              0,
                              22
                            ]
                          }
                        ]
                      },
                      "description": {
                        "urls": [
                          {
                            "url": "https://t.co/5BsmLs9y1Z",
                            "display_url": "FT.com",
                            "indices": [
                              65,
                              88
                            ]
                          }
                        ]
                      }
                    },
                    "protected": false,
                    "listed_count": 37009,
                    "created_at": "Tue Jan 13 19:28:24 +0000 2009",
                    "favourites_count": 38,
                    "utc_offset": nil,
                    "time_zone": nil,
                    "geo_enabled": false,
                    "verified": true,
                    "statuses_count": 273860,
                    "media_count": 51044,
                    "contributors_enabled": false,
                    "is_translator": false,
                    "is_translation_enabled": false,
                    "profile_background_color": "FFF1E0",
                    "profile_background_image_url": "http://abs.twimg.com/images/themes/theme1/bg.png",
                    "profile_image_url_https": "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                    "profile_banner_url": "https://pbs.twimg.com/profile_banners/18949452/1581526592",
                    "profile_image_extensions": {
                      "mediaStats": {
                        "r": {
                          "missing": nil
                        },
                        "ttl": -1
                      }
                    },
                    "profile_banner_extensions": {},
                    "blocking": false,
                    "blocked_by": false,
                    "want_retweets": false,
                    "advertiser_account_type": "none",
                    "profile_interstitial_type": "",
                    "business_profile_state": "none",
                    "translator_type": "none",
                    "followed_by": false,
                    "ext": {
                      "highlightedLabel": {
                        "ttl": -1
                      }
                    },
                    "require_some_consent": false
                  },
                  "token": "117"
                }
              ]
              expect(actual).to eq(expected)
            TEST
            program = make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
              configuration: {
                diff_elision_enabled: true,
                diff_elision_threshold: 10,
              },
            )

            expected_output = build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect(actual).to eq(expected)|,
              newline_before_expectation: true,
              expectation: proc {
                line do
                  plain "Expected "
                  # rubocop:disable Layout/LineLength
                  beta %<[{ user_id: "18949452", user: { id: 18949452, name: "Financial Times", screen_name: "FT", location: "London", url: "http://t.co/dnhLQpd9BY", entities: { url: { urls: [{ url: "http://t.co/dnhLQpd9BY", expanded_url: "http://www.ft.com/", display_url: "ft.com", indices: [0, 22] }] }, description: { urls: [{ url: "https://t.co/5BsmLs9y1Z", display_url: "FT.com", indices: [65, 88] }] } }, protected: false, listed_count: 37009, created_at: "Tue Jan 13 19:28:24 +0000 2009", favourites_count: 38, utc_offset: nil, time_zone: nil, geo_enabled: false, verified: true, statuses_count: 273860, media_count: 51044, contributors_enabled: false, is_translator: false, is_translation_enabled: false, profile_background_color: "FFF1E0", profile_background_image_url: "http://abs.twimg.com/images/themes/theme1/bg.png", profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592", profile_image_extensions: { mediaStats: { r: { missing: nil }, ttl: -1 } }, profile_banner_extensions: {}, blocking: false, blocked_by: false, want_retweets: false, advertiser_account_type: "none", profile_interstitial_type: "", business_profile_state: "none", translator_type: "none", followed_by: false, ext: { highlightedLabel: { ttl: -1 } }, require_some_consent: false }, token: "117" }]>
                  # rubocop:enable Layout/LineLength
                end

                line do
                  plain "   to eq "
                  # rubocop:disable Layout/LineLength
                  alpha %<[{ user_id: "18949452", user: { id: 18949452, name: "Financial Times", screen_name: "FT", location: "London", entities: { url: { urls: [{ url: "http://t.co/dnhLQpd9BY", expanded_url: "http://www.ft.com/", display_url: "ft.com", indices: [0, 22] }] }, description: { urls: [{ url: "https://t.co/5BsmLs9y1Z", expanded_url: "http://FT.com", indices: [65, 88] }] } }, listed_count: 37009, created_at: "Tue Jan 13 19:28:24 +0000 2009", favourites_count: 38, utc_offset: nil, time_zone: nil, geo_enabled: false, verified: true, statuses_count: 273860, media_count: 51044, contributors_enabled: false, is_translator: false, is_translation_enabled: false, profile_background_color: "FFF1E0", profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png", profile_background_tile: false, profile_image_url: "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592", profile_image_extensions: { mediaStats: { r: { missing: nil }, ttl: -1 } }, profile_banner_extensions: {}, blocking: false, blocked_by: false, want_retweets: false, advertiser_account_type: "none", advertiser_account_service_levels: [], profile_interstitial_type: "", business_profile_state: "none", translator_type: "none", followed_by: false, ext: { highlightedLabel: { ttl: -1 } }, require_some_consent: false }, token: "117" }]>
                  # rubocop:enable Layout/LineLength
                end
              },
              diff: proc {
                plain_line %|  [|
                plain_line %|    {|
                plain_line %|      user_id: "18949452",|
                plain_line %|      user: {|
                plain_line %|        id: 18949452,|
                plain_line %|        name: "Financial Times",|
                plain_line %|        screen_name: "FT",|
                plain_line %|        location: "London",|
                beta_line  %|+       url: "http://t.co/dnhLQpd9BY",|
                plain_line %|        entities: {|
                plain_line %|          url: {|
                plain_line %|            urls: [|
                gamma_line %|              # ...|
                plain_line %|            ]|
                plain_line %|          },|
                plain_line %|          description: {|
                plain_line %|            urls: [|
                plain_line %|              {|
                gamma_line %|                # ...|
                alpha_line %|-               expanded_url: "http://FT.com",|
                beta_line  %|+               display_url: "FT.com",|
                plain_line %|                indices: [|
                plain_line %|                  65,|
                plain_line %|                  88|
                plain_line %|                ]|
                plain_line %|              }|
                plain_line %|            ]|
                plain_line %|          }|
                plain_line %|        },|
                beta_line  %|+       protected: false,|
                gamma_line %|        # ...|
                alpha_line %|-       profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png",|
                alpha_line %|-       profile_background_tile: false,|
                alpha_line %|-       profile_image_url: "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",|
                beta_line  %|+       profile_background_image_url: "http://abs.twimg.com/images/themes/theme1/bg.png",|
                plain_line %|        profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",|
                plain_line %|        profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592",|
                plain_line %|        profile_image_extensions: {|
                gamma_line %|          # ...|
                plain_line %|        },|
                plain_line %|        profile_banner_extensions: {},|
                plain_line %|        blocking: false,|
                plain_line %|        blocked_by: false,|
                plain_line %|        want_retweets: false,|
                plain_line %|        advertiser_account_type: "none",|
                alpha_line %|-       advertiser_account_service_levels: [],|
                gamma_line %|        # ...|
                plain_line %|      },|
                plain_line %|      token: "117"|
                plain_line %|    }|
                plain_line %|  ]|
              },
            )

            expect(program).
              to produce_output_when_run(expected_output).
              in_color(color_enabled)
          end
        end
      end
    end

    context "if diff_elision_enabled is set to true"

    context "if diff_elision_enabled is set to false"
  end
end
