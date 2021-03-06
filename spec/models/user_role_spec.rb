require "rails_helper"

RSpec.describe UserRole do
  let(:user) { create(:user) }

  describe "uniqueness validation" do
    let(:role_name) { "test" }

    it "does not allow more than one role of the same name per user" do
      described_class.create!(user: user, name: role_name)
      expect { described_class.create!(user: user, name: role_name) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
