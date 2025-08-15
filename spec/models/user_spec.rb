require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is invalid without email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("não pode ficar em branco")
    end

    it 'is invalid with duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("já está em uso")
    end

    it 'is invalid with malformed email' do
      user = build(:user, email: 'invalid_email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("não é válido")
    end

    it 'is invalid with short password' do
      user = build(:user, password: 'short')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("é muito curto (mínimo: 8 caracteres)")
    end

    it 'normalizes email before validation' do
      user = build(:user, email: '  TEST@Example.COM  ')
      user.valid?
      expect(user.email).to eq('test@example.com')
    end

    it 'validates password presence for password reset updates' do
      user = create(:user)
      user.password = nil
      user.password_confirmation = 'password123'
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("não pode ficar em branco")
    end

    it 'validates password confirmation presence for password reset updates' do
      user = create(:user)
      user.password = 'newpassword123'
      user.password_confirmation = nil
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("não pode ficar em branco")
    end

    it 'validates email presence for email updates' do
      user = create(:user)
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("não pode ficar em branco")
    end
  end

  describe 'callbacks' do
    it 'sets verified to true before create' do
      user = create(:user, :verified)
      expect(user.verified).to be true
    end

    it 'sets verified to false when email changes on update' do
      user = create(:user, :verified)
      user.update(email: 'new@example.com')
      expect(user.verified).to be false
    end

    it 'deletes other sessions after password change' do
      user = create(:user, :verified)
      session1 = user.sessions.create!
      session2 = user.sessions.create!

      allow(Current).to receive(:session).and_return(session1.id)

      user.update!(password: 'oldpassword123', password_confirmation: 'oldpassword123')

      user.update!(password: 'newpassword123', password_confirmation: 'newpassword123')

      user.reload

      expect(user.sessions.count).to eq(1)
      expect(user.sessions.first.id).to eq(session1.id)
    end

    it 'validates password challenge when email changes' do
      user = create(:user, :verified)
      user.password_challenge = 'wrong_password'

      expect(user.update(email: 'new@example.com')).to be false
      expect(user.errors[:password_challenge]).to include("não é válido")
    end

    it 'allows email update with correct password challenge' do
      user = create(:user, :verified)
      user.password_challenge = 'password123'

      expect(user.update(email: 'new@example.com')).to be true
      expect(user.email).to eq('new@example.com')
    end

    it 'rejects email update without password challenge' do
      user = create(:user, :verified)
      user.password_challenge = nil

      user.email = 'completely_different@example.com'

      expect(user.update(email: 'completely_different@example.com')).to be false
      expect(user.errors[:password_challenge]).to include("é obrigatório")
    end

    it 'rejects email update with blank password challenge' do
      user = create(:user, :verified)
      user.password_challenge = ''

      expect(user.update(email: 'new@example.com')).to be false
      expect(user.errors[:password_challenge]).to include("não é válido")
    end
  end

  describe 'token generation' do
    it 'generates email verification token' do
      user = create(:user)
      token = user.generate_token_for(:email_verification)
      expect(token).to be_present
    end

    it 'generates password reset token' do
      user = create(:user)
      token = user.generate_token_for(:password_reset)
      expect(token).to be_present
    end

    it 'generates email verification token with email in block' do
      user = create(:user, email: 'test@example.com')
      token = user.generate_token_for(:email_verification)
      expect(token).to be_present

      decoded_token = User.find_by_token_for(:email_verification, token)
      expect(decoded_token).to eq(user)
    end

    it 'generates password reset token with password_salt in block' do
      user = create(:user)
      user.update!(password: 'newpassword123', password_confirmation: 'newpassword123')

      token = user.generate_token_for(:password_reset)
      expect(token).to be_present

      decoded_token = User.find_by_token_for(:password_reset, token)
      expect(decoded_token).to eq(user)
    end
  end

  describe 'associations' do
    it { should have_many(:sessions).dependent(:destroy) }
  end

  describe 'private methods' do
    let(:user) { create(:user) }

    describe '#should_validate_password_challenge?' do
      it 'returns true when email changed and different from was' do
        user.email = 'new@example.com'
        allow(user).to receive(:email_was).and_return('old@example.com')
        expect(user.send(:should_validate_password_challenge?)).to be true
      end

      it 'returns false when email not changed' do
        allow(user).to receive(:email_changed?).and_return(false)
        expect(user.send(:should_validate_password_challenge?)).to be false
      end

      it 'returns false when email changed but same as was' do
        user.email = 'same@example.com'
        allow(user).to receive(:email_was).and_return('same@example.com')
        expect(user.send(:should_validate_password_challenge?)).to be false
      end
    end

    describe '#password_reset_update?' do
      it 'returns true for existing user with password present' do
        user.password = 'newpassword123'
        expect(user.send(:password_reset_update?)).to be true
      end

      it 'returns true for existing user with password confirmation present' do
        user.password_confirmation = 'newpassword123'
        expect(user.send(:password_reset_update?)).to be true
      end

      it 'returns false for new record' do
        new_user = build(:user)
        expect(new_user.send(:password_reset_update?)).to be false
      end

      it 'returns false when neither password nor confirmation present' do
        user.password = nil
        user.password_confirmation = nil
        expect(user.send(:password_reset_update?)).to be false
      end
    end

    describe '#email_update?' do
      it 'returns true for existing user with email present' do
        expect(user.send(:email_update?)).to be true
      end

      it 'returns false for new record' do
        new_user = build(:user)
        expect(new_user.send(:email_update?)).to be false
      end

      it 'returns false when email is nil' do
        user.email = nil
        expect(user.send(:email_update?)).to be false
      end

      it 'returns false when email is blank' do
        user.email = ''
        expect(user.send(:email_update?)).to be false
      end
    end

    describe '#validate_password_challenge' do
      it 'returns false when password challenge is blank' do
        user.password_challenge = ''
        expect(user.send(:validate_password_challenge)).to be false
        expect(user.errors[:password_challenge]).to include("é obrigatório")
      end

      it 'returns false when password challenge is nil' do
        user.password_challenge = nil
        expect(user.send(:validate_password_challenge)).to be false
        expect(user.errors[:password_challenge]).to include("é obrigatório")
      end

      it 'returns false when password challenge is invalid' do
        user.password_challenge = 'wrong_password'
        expect(user.send(:validate_password_challenge)).to be false
        expect(user.errors[:password_challenge]).to include("é inválido")
      end

      it 'returns true when password challenge is valid' do
        user.password_challenge = 'password123'
        result = user.send(:validate_password_challenge)
        expect(result).to be true
        expect(user.errors[:password_challenge]).to be_empty
      end
    end
  end

  describe 'edge cases' do
    it 'handles email normalization with various formats' do
      test_cases = [
        [ '  SPACE@EXAMPLE.COM  ', 'space@example.com' ],
        [ 'MIXED@Example.Com', 'mixed@example.com' ],
        [ 'UPPER@EXAMPLE.COM', 'upper@example.com' ],
        [ 'lower@example.com', 'lower@example.com' ],
        [ '  ', '' ]
      ]

      test_cases.each do |input, expected|
        user = build(:user, email: input)
        user.valid?
        expect(user.email).to eq(expected)
      end
    end

    it 'handles password edge cases' do
      user = build(:user)

      expect(user.valid?).to be true

      user.password = 'a' * 7
      user.password_confirmation = 'a' * 7
      expect(user.valid?).to be false

      user.password = 'a' * 8
      user.password_confirmation = 'a' * 8
      expect(user.valid?).to be true

      user.password = 'a' * 20
      user.password_confirmation = 'a' * 20
      expect(user.valid?).to be true
    end

    it 'handles verified status edge cases' do
      user = build(:user, verified: false)
      user.save!
      expect(user.verified).to be false

      user = build(:user, verified: true)
      user.save!
      expect(user.verified).to be true

      user = build(:user, verified: nil)
      user.save!
      expect(user.verified).to be true
    end
  end
end
