class RedirectsController < ApplicationController
  def redirect_from_slug
    @link = Link.find_by!(slug: params[:id])
    redirect_to @link.url, status: :moved_permanently
  rescue ActiveRecord::RecordNotFound
    render file: 'public/404.html', status: :not_found, layout: false
  end
end
