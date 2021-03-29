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
      !!@safe || begin
        if ENV["SAFETY_ASSURED"].presence
          warn "DEPRECATED: setting SAFETY_ASSURED is deprecated. Please use DISABLE_SAFETY_CHECKS instead."
        end

        ENV["DISABLE_SAFETY_CHECKS"].presence || ENV["SAFETY_ASSURED"].presence
      end
    end

    def disable_safety_checks!
      Migration.safe = true
    end

    def safety_assured
      warn "DEPRECATED: calling safety_assured is deprecated. Please use disable_safety_checks! instead."
      disable_safety_checks!
    end

    def unsafe?
      !safe?
    end
  end
end
