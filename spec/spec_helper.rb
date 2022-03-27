# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("..", __dir__))

# Documentation: http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.default_formatter = "doc" if config.files_to_run.one?
  config.disable_monkey_patching!
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.expose_dsl_globally = true
  config.order = :random
  config.profile_examples = 2 unless config.files_to_run.one?
  config.warnings = true

  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4.
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # This option will default to `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4
  config.shared_context_metadata_behavior = :apply_to_host_groups

  Kernel.srand config.seed
end
