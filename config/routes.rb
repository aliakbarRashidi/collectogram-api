Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/api' do
    resources :collections, only: [:create]
    get 'collections/:page_number', to: 'collections#index'
    get 'collections/:unique_url/:page_number', to: 'collections#show'
  end
end
