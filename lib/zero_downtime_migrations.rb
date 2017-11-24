require "active_record"

require_relative "zero_downtime_migrations/data"
require_relative "zero_downtime_migrations/dsl"
require_relative "zero_downtime_migrations/error"
require_relative "zero_downtime_migrations/migration"
require_relative "zero_downtime_migrations/relation"
require_relative "zero_downtime_migrations/validation"
require_relative "zero_downtime_migrations/validation/add_column"
require_relative "zero_downtime_migrations/validation/add_index"
require_relative "zero_downtime_migrations/validation/ddl_migration"
require_relative "zero_downtime_migrations/validation/drop_table"
require_relative "zero_downtime_migrations/validation/find_each"
require_relative "zero_downtime_migrations/validation/mixed_migration"

ActiveRecord::Migration.send(:prepend, ZeroDowntimeMigrations::Migration)
ActiveRecord::Schema.send(:prepend, ZeroDowntimeMigrations::Migration)

module ZeroDowntimeMigrations
  GEMSPEC = name.underscore.concat(".gemspec")

  class << self
    def gemspec
      @gemspec ||= Gem::Specification.load(root.join(GEMSPEC).to_s)
    end

    def root
      @root ||= Pathname.new(__FILE__).dirname.dirname
    end

    def version
      gemspec.version.to_s
    end
  end
end
