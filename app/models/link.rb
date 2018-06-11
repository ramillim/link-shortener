# frozen_string_literal: true

class Link < ApplicationRecord
  CHARACTERS_ALLOWED_IN_SLUG = /^[0-9a-zA-Z\-_]*$/
  TRUNCATE_DAY_SQL = "DATE_TRUNC('day', created_at)"

  has_many :link_visits, dependent: :destroy

  before_validation :set_random_slug, if: proc { |link| link.slug.nil? }

  validates :slug, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true
  validate :slug_is_url_safe

  def record_visit
    link_visits.create!
  end

  def serialize_visit_stats
    {}.tap do |hash|
      hash[:total_visits] = visits_total
      hash[:visits_by_day] = visits_by_day.map { |date, count| { date.iso8601 => count } }
    end
  end

  def visits_total
    link_visits.count
  end

  def visits_by_day
    link_visits.group(TRUNCATE_DAY_SQL).order(TRUNCATE_DAY_SQL).count('link_id')
  end

  private

  def set_random_slug
    self.slug = SecureRandom.urlsafe_base64(5)
  end

  def slug_is_url_safe
    return true if CHARACTERS_ALLOWED_IN_SLUG.match?(slug)
    errors.add(:slug, 'can only include letters, numbers, `-`, and `_`')
  end
end
