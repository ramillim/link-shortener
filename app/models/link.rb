class Link < ApplicationRecord
  has_many :link_visits

  validates :slug, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true


end
