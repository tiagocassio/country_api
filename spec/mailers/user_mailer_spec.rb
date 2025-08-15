require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user) }

  describe 'password_reset' do
    let(:mail) { UserMailer.with(user: user).password_reset }

    it 'renders the headers' do
      expect(mail.subject).to eq('Reset your password')
      expect(mail.to).to eq([ user.email ])
      expect(mail.from).to eq([ 'from@example.com' ])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include('Reset my password')
    end

    it 'generates password reset token' do
      expect(mail.body.encoded).to include('sid=')
      expect(mail.body.encoded).to include('password_reset/edit')
    end
  end

  describe 'email_verification' do
    let(:mail) { UserMailer.with(user: user).email_verification }

    it 'renders the headers' do
      expect(mail.subject).to eq('Verify your email')
      expect(mail.to).to eq([ user.email ])
      expect(mail.from).to eq([ 'from@example.com' ])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include('Yes, use this email for my account')
    end

    it 'generates email verification token' do
      expect(mail.body.encoded).to include('sid=')
      expect(mail.body.encoded).to include('email_verification')
    end
  end
end
