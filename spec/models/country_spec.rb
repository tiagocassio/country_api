require 'rails_helper'

RSpec.describe Country, type: :model do
  describe 'validations' do
    it 'is valid with a name' do
      country = Country.new(name: 'Brazil')
      expect(country).to be_valid
    end

    it 'is invalid without a name' do
      country = Country.new(name: nil)
      expect(country).not_to be_valid
      expect(country.errors[:name]).to include("não pode ficar em branco")
    end
  end
end
