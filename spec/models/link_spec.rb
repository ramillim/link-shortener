require 'rails_helper'

RSpec.describe Link do
  let(:long_url) { 'https://some.long.url.com/shorten/me' }

  describe 'validations' do
    let!(:short_link) { described_class.create!(slug: 'link', url: long_url) }
    let(:duplicate_slug) { described_class.new(slug: 'link', url: long_url) }

    before do
      duplicate_slug.save
    end

    describe 'slug' do
      it 'validates uniqueness' do
        expect(duplicate_slug).to be_invalid
        expect(duplicate_slug.errors[:slug]).to include('has already been taken')
      end

      context 'when a custom slug is provided' do
        it 'only allows letters and numbers' do
          short_link.slug = 'this/is/unsafe'
          short_link.save
          expect(short_link.errors[:slug])
            .to include('can only include letters, numbers, `-`, and `_`')
        end

        it 'allows hyphens' do
          short_link.slug = 'custom-slug'
          short_link.save
          expect(short_link).to be_valid
        end

        it 'allows underscores' do
          short_link.slug = 'custom_slug'
          short_link.save
          expect(short_link).to be_valid
        end
      end
    end

    describe 'url' do
      it 'validates uniqueness' do
        expect(duplicate_slug).to be_invalid
        expect(duplicate_slug.errors[:url]).to include('has already been taken')
      end
    end
  end

  describe 'creating a short link' do
    context 'when a custom slug is not provided' do
      let(:link) { described_class.create!(url: long_url) }

      it 'generates a random slug' do
        expect(link.slug).to be_present
      end

      it 'generates a slug that is 7 characters long' do
        expect(link.slug.size).to eq(7)
      end

      it 'associates the random slug with the url' do
        expect(link.url).to eq(long_url)
      end
    end

    context 'when a custom slug is provided' do
      let(:link) { described_class.create!(url: long_url, slug: 'custom-slug') }

      it 'associates the custom slug with the url' do
        expect(link.slug).to eq('custom-slug')
        expect(link.url).to eq(long_url)
      end
    end
  end

  describe '#record_visit' do
    let(:link) { described_class.create!(url: long_url) }

    it 'creates an associated LinkVisit' do
      expect { link.record_visit }.to change(link.link_visits, :count).by(1)
    end
  end

  describe '#visits_total' do
    let(:link) { described_class.create!(url: long_url) }

    before do
      2.times { link.record_visit }
    end

    it 'calculates the number of visits' do
      expect(link.visits_total).to eq(2)
    end
  end

  describe '#visits_by_day' do
    let(:link) { described_class.create!(url: long_url) }

    before do
      5.times { link.link_visits.create!(created_at: '2018-01-05') }
      2.times { link.link_visits.create!(created_at: '2018-01-01') }
      3.times { link.link_visits.create!(created_at: '2018-01-03') }
    end

    it 'returns a histogram of visits by day' do
      expect(link.visits_by_day).to eq(Time.utc(2018, 1, 1) => 2,
                                       Time.utc(2018, 1, 3) => 3,
                                       Time.utc(2018, 1, 5) => 5)
    end
  end
end
