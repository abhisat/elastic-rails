Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
   match '/elastic_test' => 'application#elastic_test', via: :get
end
