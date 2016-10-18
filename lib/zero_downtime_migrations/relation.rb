module ZeroDowntimeMigrations
  module Relation
    prepend Data

    def each(*)
      return super unless Migration.migrating? && Migration.unsafe?
      error = "Using ActiveRecord::Relation#each is unsafe!"
      correction = "Instead, let's use the find_each method to query in batches."
      raise UnsafeMigrationError.new(error, correction)
    end
  end
end
