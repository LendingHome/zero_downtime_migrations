require "active_record"
require "pathname"

require_relative "zero_downtime_migrations/migration"
require_relative "zero_downtime_migrations/relation"
require_relative "zero_downtime_migrations/validation"
require_relative "zero_downtime_migrations/unsafe_migration_error"

require_relative "zero_downtime_migrations/add_column"
require_relative "zero_downtime_migrations/add_index"

ActiveRecord::Migration.send(:prepend, ZeroDowntimeMigrations::Migration)
ActiveRecord::Relation.send(:prepend, ZeroDowntimeMigrations::Relation)

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
