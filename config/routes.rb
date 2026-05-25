require 'sidekiq/web'
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :orders, only: [] do
        collection do
          post :place_order
        end
      end
    end
  end
  # Thêm dòng này để mount giao diện Sidekiq UI vào đường dẫn /sidekiq 👇
  mount Sidekiq::Web => '/sidekiq'
end