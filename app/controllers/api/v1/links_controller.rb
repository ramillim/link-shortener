# frozen_string_literal: true

module Api
  module V1
    class LinksController < ApiController
      before_action :find_link, only: :show

      def show
        response = { data: link_data }
        response[:meta] = @link.serialize_visit_stats if params[:stats].present?
        render json: response, status: :ok
      end

      def create
        @link = Link.new(link_params)

        if @link.save
          render json: { data: link_data }, status: :created
        else
          render json: { errors: @link.errors.full_messages }, status: :bad_request
        end
      end

      private

      def link_params
        params.require(:link).permit(:slug, :url)
      end

      def link_data
        {}.tap do |hash|
          hash[:short_url] = request.base_url + "/#{@link.slug}"
          hash[:url] = @link.url
        end
      end

      def find_link
        @link = Link.find_by!(slug: params[:slug])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: 'No record found that matches the given slug' }, status: :not_found
      end
    end
  end
end
