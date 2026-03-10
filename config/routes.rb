Rails.application.routes.draw do
  root "dashboard#index"
  get "dashboard", to: "dashboard#index", as: :dashboard

  resources :clients do
    resources :matters, shallow: true do
      resources :tasks, shallow: true
      resources :notes, only: [:create, :destroy, :edit, :update]
      member do
        patch :close
        patch :reopen
      end
    end
  end
end
