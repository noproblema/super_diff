module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      DEFAULTS = [
        CustomObject,
        Array,
        Hash,
        Primitive,
        String,
        TimeLike,
        DefaultObject,
      ].freeze
    end
  end
end
