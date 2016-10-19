RSpec.describe ZeroDowntimeMigrations::Validation do
  subject { described_class.new(migration, *args) }

  let(:migration) { double("migration") }
  let(:args) { [] }

  describe ".validate!" do
    let(:error) { ZeroDowntimeMigrations::UndefinedValidationError }

    it "raises UndefinedValidationError if one does not exist" do
      expect { described_class.validate!(:invalid?) }.to raise_error(error)
    end
  end

  describe "#args" do
    it "returns the initialized args" do
      expect(subject.args).to eq(args)
    end
  end

  describe "#error" do
    let(:args) { [:one, :two] }
    let(:error) { ZeroDowntimeMigrations::UnsafeMigrationError }

    it "raises a new UnsafeMigrationError" do
      expect { subject.error!(*args) }.to raise_error(error)
    end
  end

  describe "#migration" do
    it "returns the initialized migration" do
      expect(subject.migration).to eq(migration)
    end
  end

  describe "#options" do
    context "when the last arg is a hash" do
      let(:args) { [:one, :two, { three: :four }] }
      it "returns the last arg" do
        expect(subject.options).to eq(three: :four)
      end
    end

    context "when the last arg is not a hash" do
      let(:args) { [:one, :two] }

      it "returns the an empty hash" do
        expect(subject.options).to eq({})
      end
    end
  end

  describe "#validate!" do
    it "raises NotImplementedError" do
      expect { subject.validate! }.to raise_error(NotImplementedError)
    end
  end
end
