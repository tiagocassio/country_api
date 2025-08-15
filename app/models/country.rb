class Country < ApplicationRecord
  include Sluggable

  validates :name, presence: true
end
