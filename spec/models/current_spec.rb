require "rails_helper"

RSpec.describe Current, type: :model do
  describe "attributes" do
    before do
      @session = OpenStruct.new(user: "test_user")
      Current.session = @session
      Current.user_agent = "Mozilla/5.0"
      Current.ip_address = "127.0.0.1"
    end

    it "has a session attribute" do
      expect(Current.session).to eq(@session)
    end

    it "has a user_agent attribute" do
      expect(Current.user_agent).to eq("Mozilla/5.0")
    end

    it "has an ip_address attribute" do
      expect(Current.ip_address).to eq("127.0.0.1")
    end

    it "delegates user to session" do
      expect(Current.user).to eq("test_user")
    end

    it "delegates user returns nil if session is nil" do
      Current.session = nil
      expect(Current.user).to be_nil
    end
  end
end
