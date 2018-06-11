# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RedirectsController, type: :request do
  let(:long_url) { 'https://long.url.com/shorten/me?something=1&anotherParam=42' }

  describe 'GET /:slug' do
    let!(:short_link) { Link.create!(url: long_url) }

    context 'when the slug for a shortened link is requested' do
      it 'redirects to the link' do
        get "/#{short_link.slug}"
        expect(response).to have_http_status(:moved_permanently)
      end
    end

    context 'when the slug does not exist' do
      it 'redirects to the not found page' do
        get "/does-not-exist"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
