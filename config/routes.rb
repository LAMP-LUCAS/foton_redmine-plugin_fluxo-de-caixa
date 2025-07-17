# frozen_string_literal: true

RedmineApp::Application.routes.draw do
  resources :cash_flow_entries do
    collection do
      get :import_form
      post :import
      get :export
    end
  end
  # Rota para configurações do plugin, sem escopo
  get 'cash_flow_settings', to: 'cash_flow_settings#index', as: 'cash_flow_settings'
  post 'cash_flow_settings', to: 'cash_flow_settings#update'
end