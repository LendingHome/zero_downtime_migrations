module ZeroDowntimeMigrations
  module Relation
    prepend Data

    def each(*)
      Validation.validate!(:find_each)
      super
    end
  end
end
