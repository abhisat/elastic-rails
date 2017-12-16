Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
   match '/page_views' => 'application#page_views', via: :post
end
