# frozen_string_literal: true

Rails.application.routes.draw do
  # ヘルスチェック用
  get '/health', to: 'health#check'

  # 家計簿用
  root to: 'products#index'
  resources :products
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
