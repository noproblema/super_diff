module SuperDiff
  module ObjectInspection
    autoload :InspectionTree, "super_diff/object_inspection/inspection_tree"
    autoload(
      :InspectionTreeBuilders,
      "super_diff/object_inspection/inspection_tree_builders",
    )
    autoload :Nodes, "super_diff/object_inspection/nodes"
    autoload(
      :PrefixForNextNode,
      "super_diff/object_inspection/prefix_for_next_node",
    )

    def self.inspect(object, as_lines:, **rest)
      SuperDiff::RecursionGuard.guarding_recursion_of(object) do
        inspection_tree = InspectionTreeBuilders::Main.call(object)

        if as_lines
          inspection_tree.render_to_lines(object, **rest)
        else
          inspection_tree.render_to_string(object)
        end
      end
    end
  end
end
