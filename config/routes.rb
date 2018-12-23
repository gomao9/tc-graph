Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "scores#index"
  get 'about', to: 'about#index'
  get 'wastes', to: 'scores#wastes'
  get 'changes', to: 'scores#changes'
  get ':subject', to: 'scores#index'
end
