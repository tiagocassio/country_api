module Sluggable
  extend ActiveSupport::Concern

  included do
    extend FriendlyId

    friendly_id :slug, use: :slugged

    before_create :set_slug

    def set_slug
      return if slug.present?

      self.slug = SecureRandom.uuid_v4.delete("-")
    end
  end
end
