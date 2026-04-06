Rails.application.routes.draw do
  namespace :eventual, defaults: { business: 'eventual' } do
    controller :time do
      get 'repeat_form', action: 'repeat_form'
    end
    resources :plans do
      collection do
        get :calendar
      end
      member do
        get 'calendar' => :show_calendar
      end
    end
    resources :time_items, only: [:index] do
      collection do
        get :select
      end
    end
    resources :places do
      resources :seats
      resources :plans, controller: 'place/plans' do
        collection do
          get 'event/:event_id' => :event
        end
      end
    end
    resources :events do
      collection do
        get :summary
      end
      resources :plans do
        collection do
          get 'place/:place_id' => :place
        end
      end
    end

    namespace :admin, defaults: { namespace: 'admin' } do
      root 'home#index'
      resources :apps
      resources :time_lists do
        resources :time_items
      end
      resources :time_items, only: [] do
        collection do
          get :default
        end
      end
      resources :place_taxons
      resources :places do
        resources :halls
        resources :seats
        resources :plans, controller: 'place/plans' do
          collection do
            post :sync
          end
        end
      end
      resources :plans
      resources :plan_items do
        patch :qrcode, on: :member
        resources :bookings do
          collection do
            delete '' => :destroy
          end
        end
        resources :plan_attenders do
          collection do
            delete '' => :destroy
          end
          member do
            put :attend
            put :absent
          end
        end
      end
      resources :crowds do
        resources :crowd_members do
          collection do
            delete '' => :destroy
          end
        end
      end
      resources :event_taxons
      resources :events do
        collection do
          get :plan
          get :summary
        end
        member do
          match :edit_plan, via: [:get, :post]
          match :update_plan, via: [:get, :post]
        end
        resources :plans, controller: 'event/plans'
        resources :event_participants do
          collection do
            post :check
            post :attend
            delete '' => :destroy
          end
          member do
            patch :quit
          end
        end
        resources :event_items
      end
      resources :event_items, only: [] do
        member do
          get 'plan' => :edit_plan
          patch 'plan' => :update_plan
          delete 'plan' => :destroy_plan
        end
      end
    end

    namespace :my, defaults: { namespace: 'my' } do
      resources :time_plans
      resources :places
      resources :plans, only: [:index] do
        resources :plan_joins
      end
    end

    namespace :me, defaults: { namespace: 'me' } do
      resources :plan_items
    end
  end

  resolve 'Eventual::PlanJoin' do |model|
    url_for(controller: 'eventual/my/plan_joins', action: 'show', plan_id: model.plan_id, id: model.id)
  end
end
