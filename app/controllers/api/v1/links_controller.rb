module Api
  module V1
    class LinksController < ApplicationController
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
    end
  end
end
