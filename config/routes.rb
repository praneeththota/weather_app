Rails.application.routes.draw do
  root "forecast#new"
  get "forecast", to: "forecast#show"
end
