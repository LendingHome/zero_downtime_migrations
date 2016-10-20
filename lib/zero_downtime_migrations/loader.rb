module ZeroDowntimeMigrations
  module Loader
    def initialize(*)
      ActiveRecord::Base.send(:prepend, Data)
      ActiveRecord::Migration.send(:prepend, Migration)
      ActiveRecord::Relation.send(:prepend, Relation)
      ActiveRecord::Schema.send(:prepend, Migration)
      super
    end
  end
end
