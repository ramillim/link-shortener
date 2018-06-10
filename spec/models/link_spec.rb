require 'rails_helper'

RSpec.describe Link do
  describe 'validations' do
    let(:url) { 'https://some.long.url.com/shorten/me' }
    let(:duplicate_slug) { described_class.new(slug: 'link', url: url) }

    before do
      described_class.create!(slug: 'link', url: url)
      duplicate_slug.save
    end

    it 'validates the uniqueness of the slug' do
      expect(duplicate_slug).to be_invalid
      expect(duplicate_slug.errors[:slug]).to include('has already been taken')
    end

    it 'validates the uniqueness of the url' do
      expect(duplicate_slug).to be_invalid
      expect(duplicate_slug.errors[:url]).to include('has already been taken')
    end
  end

  describe 'shortening a url' do
    it 'encodes a url' do

    end
  end
end
