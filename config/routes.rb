Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :scores do
    get :wastes, on: :collection
    get :changes, on: :collection
  end
end
