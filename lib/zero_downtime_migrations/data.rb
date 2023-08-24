module ZeroDowntimeMigrations
  module Data
    def initialize(*, **)
      Migration.data = true
      super
    end
  end
end
