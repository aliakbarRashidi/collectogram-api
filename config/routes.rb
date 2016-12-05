Rails.application.routes.draw do
  scope '/api' do
    post 'collections', to: 'collections#create'
    get 'collections', to: 'collections#index'
    get 'collections/:unique_url', to: 'collections#show'
  end
end
