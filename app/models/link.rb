class Link < ApplicationRecord
  CHARACTERS_ALLOWED_IN_SLUG = /^[0-9a-zA-Z\-_]*$/

  has_many :link_visits

  before_validation :set_random_slug, if: proc { |link| link.slug.nil? }

  validates :slug, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
  validate :slug_is_url_safe

  private

  def set_random_slug
    self.slug = SecureRandom.urlsafe_base64(5)
  end

  def slug_is_url_safe
    return true if CHARACTERS_ALLOWED_IN_SLUG.match?(slug)
    errors.add(:slug, 'Custom slug can only include letters, numbers, `-`, and `_`')
  end
end
