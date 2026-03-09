Rails.application.routes.draw do
  root "clients#index"

  resources :clients do
    resources :matters, shallow: true do
      resources :tasks, shallow: true
    end
  end
end
