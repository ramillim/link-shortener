Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resource :links, only: :create
    end
  end
end
