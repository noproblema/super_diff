module SuperDiff
  module IntegrationTests
    PROJECT_DIRECTORY = Pathname.new("../../..").expand_path(__dir__)

    def make_plain_test_program(test)
      <<~PROGRAM
        #{set_up_with("super_diff/rspec")}
        #{describe_block_including(test)}
      PROGRAM
    end

    def make_rspec_active_record_program(test)
      <<~PROGRAM
        #{
          set_up_active_record_around do
            set_up_with("super_diff/rspec", "super_diff/active_record")
          end
        }
        #{describe_block_including(test)}
      PROGRAM
    end

    def make_rspec_rails_test_program(test)
      <<~PROGRAM
        #{
          set_up_active_record_around do
            set_up_with("super_diff/rspec-rails")
          end
        }
        #{describe_block_including(test)}
      PROGRAM
    end

    def set_up_active_record_around(&block)
      <<~PROGRAM
        require "active_record"

        ActiveRecord::Base.establish_connection(
          adapter: "sqlite3",
          database: ":memory:"
        )

        #{block.call}

        Dir.glob(SUPPORT_DIR.join("models/active_record/*.rb")).each do |path|
          require path
        end
      PROGRAM
    end

    def set_up_with(*libraries)
      <<~SETUP
        PROJECT_DIRECTORY = Pathname.new("#{PROJECT_DIRECTORY}")
        SUPPORT_DIR = PROJECT_DIRECTORY.join("spec/support")
        INSIDE_INTEGRATION_TEST = true

        $LOAD_PATH.unshift(PROJECT_DIRECTORY.join("lib"))
        #\$LOAD_PATH.unshift(PROJECT_DIRECTORY)

        begin
          require "pry-byebug"
        rescue LoadError
          require "pry-nav"
        end

        RSpec.configure do |config|
          config.color_mode = :on
        end

#{libraries.map { |library| %(        require "#{library}") }.join("\n")}

        Dir.glob(SUPPORT_DIR.join("{diff_formatters,models,operational_sequencers,operation_sequences}/*.rb")).each do |path|
          require path
        end
      SETUP
    end

    def describe_block_including(test)
      <<~PROGRAM
        RSpec.describe "test" do
          it "passes" do
        #{reindent(test, level: 2)}
          end
        end
      PROGRAM
    end

    def build_expected_output(
      snippet:,
      expectation:,
      newline_before_expectation: false,
      diff: nil
    )
      colored do
        line "Failures:\n"

        line "1) test passes", indent_by: 2

        line indent_by: 5 do
          white "Failure/Error: "
          plain snippet
        end

        if diff || newline_before_expectation
          newline
        end

        indent by: 7 do
          evaluate_block(&expectation)

          if diff
            newline

            white_line "Diff:"

            newline

            line do
              blue "┌ (Key) ──────────────────────────┐"
            end

            line do
              blue "│ "
              red "‹-› in expected, not in actual"
              blue "  │"
            end

            line do
              blue "│ "
              green "‹+› in actual, not in expected"
              blue "  │"
            end

            line do
              blue "│ "
              text "‹ › in both expected and actual"
              blue " │"
            end

            line do
              blue "└─────────────────────────────────┘"
            end

            newline

            evaluate_block(&diff)

            newline
          end
        end
      end
    end

    def colored(&block)
      SuperDiff::Tests::Colorizer.call(&block).to_s.chomp
    end

    def reindent(code, level: 0)
      code.strip.split("\n").map { |line| ("  " * level) + line }.join("\n")
    end
  end
end