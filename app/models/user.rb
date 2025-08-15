class User < ApplicationRecord
  include Sluggable

  has_secure_password

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_many :sessions, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 8 }
  validates :password, presence: true, if: :password_reset_update?
  validates :email, presence: true, if: :email_update?
  validates :password_confirmation, presence: true, if: :password_reset_update?

  normalizes :email, with: -> { _1.strip.downcase }

  before_create do
    self.verified = true if verified.nil?
  end

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  before_validation :validate_password_challenge, if: :should_validate_password_challenge?

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  attr_accessor :password_challenge

  private

  def should_validate_password_challenge?
    !new_record? && email_changed? && email != email_was
  end

  def password_reset_update?
    !new_record? && (password.present? || password_confirmation.present?)
  end

  def email_update?
    !new_record? && email.present?
  end

  def validate_password_challenge
    if password_challenge.blank?
      errors.add(:password_challenge, I18n.t("errors.messages.password_challenge.required"))
      return false
    end

    unless authenticate(password_challenge)
      errors.add(:password_challenge, I18n.t("errors.messages.password_challenge.invalid"))
      return false
    end

    true
  end
end
