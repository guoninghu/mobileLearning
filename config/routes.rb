MobileLearning::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  
  resources :user do
    collection do
      get 'login'
      get 'logout'
      get 'register'
      post 'login'
      post 'register'
    end
  end
  
  resources :amateur do
    collection do
      get 'select'
      get 'edit'
      post 'add'
      post 'delete'
    end
  end

  resources :learning do
    collection do
      get 'list'
      get 'word'
      get 'math'
    end
  end
  
  resources :achievement do
    collection do
      get 'list'
    end
  end

  resources :question do
    member do
      post 'answer'
    end
  end

  resources :questionset do
    member do
      get 'ask'
      get 'start'
      get 'summary'
    end
    collection do
      get 'ask'
      post 'ask'
    end
  end

  resources :math do
    collection do
      get 'teach'
    end
  end

  resources :spellingbee do
    collection do
      get 'show'
      post 'crawl'
      get 'add'
      get 'practice'
      post 'result'
    end
  end

  root :to => 'learning#list'
end
