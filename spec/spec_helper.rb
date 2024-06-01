# frozen_string_literal: true

require_relative "../lib/envy"

ENV_FILE = File.expand_path("./support/.env.yml", __dir__)
ENV_DEV_FILE = File.expand_path("./support/.env.dev.yml", __dir__)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |rspec|
    rspec.syntax = :expect
  end

  config.before(:each) do
    ENV.clear
    File.chmod 0o644, ENV_FILE, ENV_DEV_FILE
  end

  config.after(:suite) do
    File.chmod 0o644, ENV_FILE, ENV_DEV_FILE
  end
end
