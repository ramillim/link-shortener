# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::LinksController, type: :request do
  let(:long_url) { 'https://long.url.com/shorten/me?something=1&anotherParam=42' }

  describe 'GET /api/v1/links/:slug' do
    let!(:short_link) { Link.create!(url: long_url) }

    context 'when an existing resource is requested' do
      it 'responds with ok' do
        get api_v1_link_path(short_link.slug), as: :json
        expect(response).to have_http_status(:ok)
      end

      context 'the response body contains' do
        before do
          get api_v1_link_path(short_link.slug), as: :json
        end

        it 'the short_url' do
          expect(json_response[:data][:short_url]).to eq("http://www.example.com/#{short_link.slug}")
        end

        it 'the original url' do
          expect(json_response[:data][:url]).to eq(long_url)
        end

        it 'the created_at timestamp in ISO 8601 format' do
          expect(json_response[:data][:created_at]).to eq(short_link.created_at.iso8601)
        end
      end

      context 'when the stats parameter is provided' do
        before do
          2.times { short_link.link_visits.create!(created_at: '2018-01-01') }
          short_link.link_visits.create!(created_at: '2018-01-03')

          get "/api/v1/links/#{short_link.slug}?stats=true", as: :json
        end

        it 'includes the number of times the link has been visited total' do
          expect(json_response[:meta][:total_visits]).to eq(3)
        end

        it 'includes a histogram of the number of visits per day' do
          expect(json_response[:meta][:visits_by_day]).to eq(
            [
              { '2018-01-01T00:00:00Z': 2 },
              { '2018-01-03T00:00:00Z': 1 },
            ]
          )
        end

      end
    end

    context 'when a non-existent resource is requested' do
      it 'responds with data about the link' do
        get api_v1_link_path('not-found'), as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'CREATE /api/v1/links' do
    context 'when a custom slug is provided' do
      let(:params) do
        { link: { slug: 'custom-slug', url: long_url } }
      end

      before do
        post api_v1_links_path, params: params, as: :json
      end

      it 'creates the resource' do
        expect(response).to have_http_status(:created)
      end

      it 'responds with the short_url' do
        expect(json_response[:data][:short_url]).to eq('http://www.example.com/custom-slug')
      end

      it 'responds with the original url' do
        expect(json_response[:data][:url]).to eq(long_url)
      end
    end

    context 'when an invalid custom slug is provided' do
      let(:params) do
        { link: { slug: '!!!invalid@@@', url: long_url } }
      end

      before do
        post api_v1_links_path, params: params, as: :json
      end

      it 'responds with a bad_request' do
        expect(response).to have_http_status(:bad_request)
        expect(json_response[:errors]).to include(/Slug can only include/)
      end
    end

    context 'when no custom slug is provided' do
      let(:params) do
        { link: { url: long_url } }
      end

      before do
        post api_v1_links_path, params: params, as: :json
      end

      it 'creates the resource' do
        expect(response).to have_http_status(:created)
      end

      it 'responds with a generated short_url' do
        expect(json_response[:data][:short_url]).to be_present
      end

      it 'responds with the original url' do
        expect(json_response[:data][:url]).to eq(long_url)
      end
    end

    context 'when a duplicate slug is provided' do
      let(:params) do
        { link: { slug: 'some-slug', url: long_url } }
      end

      before do
        Link.create!(slug: 'some-slug', url: 'http://someother.url.com/')
        post api_v1_links_path, params: params, as: :json
      end

      it 'responds with a bad_request' do
        expect(response).to have_http_status(:bad_request)
        expect(json_response[:errors]).to include('Slug has already been taken')
      end
    end

    context 'when no url is provided' do
      let(:params) do
        { link: { url: '' } }
      end

      before do
        post api_v1_links_path, params: params, as: :json
      end

      it 'responds with a bad_request' do
        expect(response).to have_http_status(:bad_request)
        expect(json_response[:errors]).to include("Url can't be blank")
      end
    end

    context 'when a duplicate url is provided' do
      let(:params) do
        { link: { url: long_url } }
      end

      before do
        Link.create(url: long_url)
        post api_v1_links_path, params: params, as: :json
      end

      it 'responds with a 409 conflict' do
        expect(response).to have_http_status(:conflict)
      end

      it 'responds with the existing short link' do
        short_url = "http://www.example.com/#{Link.first.slug}"

        expect(json_response[:errors])
          .to include("A short link for the url already exists at: #{short_url}")
      end
    end
  end
end
