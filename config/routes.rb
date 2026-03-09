Rails.application.routes.draw do
  root "clients#index"

  resources :clients do
    resources :matters, shallow: true do
      resources :tasks, shallow: true
      resources :notes, only: [:create, :destroy, :edit, :update]
    end
  end
end
