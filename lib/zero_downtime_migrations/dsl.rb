module ZeroDowntimeMigrations
  module DSL
    attr_accessor :current, :data, :ddl, :index, :safe

    def data?
      !!@data
    end

    def ddl?
      !!@ddl
    end

    def index?
      !!@index
    end

    def migrating?
      !!@current
    end

    def mixed?
      [data?, ddl?, index?].select(&:itself).size > 1
    end

    def safe?
      !!@safe || ENV["SAFETY_ASSURED"].presence
    end

    def disable_safety_checks!
      Migration.safe = true
    end

    def unsafe?
      !safe?
    end
  end
end
