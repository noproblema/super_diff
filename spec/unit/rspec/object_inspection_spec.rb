require "spec_helper"

RSpec.describe SuperDiff::ObjectInspection, type: :unit do
  describe ".inspect", "for RSpec objects" do
    context "given a hash-including-<something>" do
      context "given as_lines: false" do
        it "returns an inspected version of the object" do
          string = described_class.inspect(
            a_hash_including(foo: "bar", baz: "qux"),
            as_lines: false,
          )
          expect(string).to eq(
            %(#<a hash including (foo: "bar", baz: "qux")>),
          )
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the object as multiple Lines" do
          tiered_lines = described_class.inspect(
            a_hash_including(foo: "bar", baz: "qux"),
            as_lines: true,
            type: :delete,
            indentation_level: 1,
          )
          expect(tiered_lines).to match([
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %[#<a hash including (],
              collection_bookend: :open,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              prefix: %[foo: ],
              value: %["bar"],
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              prefix: %[baz: ],
              value: %["qux"],
              add_comma: false,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %[)>],
              collection_bookend: :close,
            ),
          ])
        end
      end
    end

    context "given a collection-including-<something>" do
      context "given as_lines: false" do
        it "returns an inspected version of the object" do
          string = described_class.inspect(
            a_collection_including(1, 2, 3),
            as_lines: false,
          )
          expect(string).to eq(
            %(#<a collection including (1, 2, 3)>),
          )
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the object as multiple Lines" do
          tiered_lines = described_class.inspect(
            a_collection_including(1, 2, 3),
            as_lines: true,
            type: :delete,
            indentation_level: 1,
          )
          expect(tiered_lines).to match([
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %[#<a collection including (],
              collection_bookend: :open,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              value: %[1],
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              value: %[2],
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              value: %[3],
              add_comma: false,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %[)>],
              collection_bookend: :close,
            ),
          ])
        end
      end
    end

    context "given a fuzzy object" do
      context "given as_lines: false" do
        it "returns an inspected version of the object" do
          string = described_class.inspect(
            an_object_having_attributes(foo: "bar", baz: "qux"),
            as_lines: false,
          )
          expect(string).to eq(
            %(#<an object having attributes (foo: "bar", baz: "qux")>),
          )
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the object as multiple Lines" do
          tiered_lines = described_class.inspect(
            an_object_having_attributes(foo: "bar", baz: "qux"),
            as_lines: true,
            type: :delete,
            indentation_level: 1,
          )
          expect(tiered_lines).to match([
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %[#<an object having attributes (],
              collection_bookend: :open,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              prefix: %[foo: ],
              value: %["bar"],
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              prefix: %[baz: ],
              value: %["qux"],
              add_comma: false,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %[)>],
              collection_bookend: :close,
            ),
          ])
        end
      end
    end

    context "given a collection-containing-exactly-<something>" do
      context "given as_lines: false" do
        it "returns an inspected version of the object" do
          string = described_class.inspect(
            a_collection_containing_exactly("foo", "bar", "baz"),
            as_lines: false,
          )
          expect(string).to eq(
            %(#<a collection containing exactly ("foo", "bar", "baz")>),
          )
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the object as multiple Lines" do
          tiered_lines = described_class.inspect(
            a_collection_containing_exactly("foo", "bar", "baz"),
            as_lines: true,
            type: :delete,
            indentation_level: 1,
          )
          expect(tiered_lines).to match([
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %[#<a collection containing exactly (],
              collection_bookend: :open,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              value: %["foo"],
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              value: %["bar"],
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              value: %["baz"],
              add_comma: false,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %[)>],
              collection_bookend: :close,
            ),
          ])
        end
      end
    end

    context "given a kind-of-<something>" do
      context "given as_lines: false" do
        it "returns an inspected version of the object" do
          string = described_class.inspect(
            a_kind_of(Symbol),
            as_lines: false,
          )
          expect(string).to eq(%(#<a kind of Symbol>))
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the object as a single Line" do
          tiered_lines = described_class.inspect(
            a_kind_of(Symbol),
            as_lines: true,
            type: :delete,
            indentation_level: 1,
          )
          expect(tiered_lines).to match([
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %[#<a kind of Symbol>],
            ),
          ])
        end
      end
    end

    context "given an-instance-of-<something>" do
      context "given as_lines: false" do
        it "returns an inspected version of the object" do
          string = described_class.inspect(
            an_instance_of(Symbol),
            as_lines: false,
          )
          expect(string).to eq(%(#<an instance of Symbol>))
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the object" do
          tiered_lines = described_class.inspect(
            an_instance_of(Symbol),
            as_lines: true,
            type: :delete,
            indentation_level: 1,
          )
          expect(tiered_lines).to match([
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %[#<an instance of Symbol>],
            ),
          ])
        end
      end
    end

    context "given a-value-within-<something>" do
      context "given as_lines: false" do
        it "returns an inspected version of the object" do
          string = described_class.inspect(
            a_value_within(1).of(Time.utc(2020, 4, 9)),
            as_lines: false,
          )
          expect(string).to eq(
            %(#<a value within 1 of 2020-04-09 00:00:00.000 UTC +00:00 (Time)>),
          )
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the object" do
          tiered_lines = described_class.inspect(
            a_value_within(1).of(Time.utc(2020, 4, 9)),
            as_lines: true,
            type: :delete,
            indentation_level: 1,
          )
          expect(tiered_lines).to match([
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %(#<a value within 1 of 2020-04-09 00:00:00.000 UTC +00:00 (Time)>),
            ),
          ])
        end
      end
    end

    # TODO: Test InstanceDouble, ClassDouble, ObjectDouble
    context "given a Double" do
      # TODO: Test named double
      context "that is anonymous" do
        context "given as_lines: false" do
          it "returns an inspected version of the object" do
            string = described_class.inspect(
              double(foo: "bar", baz: "qux"),
              as_lines: false,
            )
            expect(string).to eq(
              %(#<Double (anonymous) foo: "bar", baz: "qux">),
            )
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the object as multiple Lines" do
            tiered_lines = described_class.inspect(
              double(foo: "bar", baz: "qux"),
              as_lines: true,
              type: :delete,
              indentation_level: 1,
            )
            expect(tiered_lines).to match([
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: %(#<Double (anonymous) {),
                collection_bookend: :open,
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                prefix: %(foo: ),
                value: %("bar"),
                add_comma: true,
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                prefix: %(baz: ),
                value: %("qux"),
                add_comma: false,
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: %(}>),
                collection_bookend: :close,
              ),
            ])
          end
        end
      end
    end
  end
end
