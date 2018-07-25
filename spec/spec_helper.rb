require "simplecov"
SimpleCov.start { add_filter("/vendor/bundle/") }

require File.expand_path("../../lib/zero_downtime_migrations", __FILE__)
ActiveRecord::Migration.verbose = false

require "combustion"
Combustion.initialize!(:active_record)

require "rspec/rails"
RSpec::Expectations.configuration.on_potential_false_positives = :nothing

RSpec.configure do |config|
  config.filter_run :focus
  config.raise_errors_for_deprecations!
  config.run_all_when_everything_filtered = true
  config.use_transactional_fixtures = true
end
