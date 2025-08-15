require 'rails_helper'

RSpec.describe Session, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'callbacks' do
    before do
      allow(Current).to receive(:user_agent).and_return('TestAgent')
      allow(Current).to receive(:ip_address).and_return('127.0.0.1')
    end

    it 'sets user_agent and ip_address before create' do
      session = Session.create!(user: user)
      expect(session.user_agent).to eq('TestAgent')
      expect(session.ip_address).to eq('127.0.0.1')
    end
  end

  describe 'sluggable concern' do
    it 'includes Sluggable module' do
      expect(Session.included_modules).to include(Sluggable)
    end
  end
end
