Rails.application.routes.draw do
  get ':id', to: 'redirects#redirect_from_slug'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :links, param: :slug, only: [:create, :show]
    end
  end
end
