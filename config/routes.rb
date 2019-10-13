Rails.application.routes.draw do
  resources :links do
    collection do
      post :get_link_artlist
      post :get_link_emvn
      get :check_link
    end
  end
  root :to => "links#index"
end
