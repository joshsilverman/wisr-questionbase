OauthClientDemo::Application.routes.draw do

  # omniauth
  match '/auth/:provider/callback', :to => 'user_sessions#create'
  match '/auth/failure', :to => 'user_sessions#failure'

  # Custom logout
  match '/logout', :to => 'user_sessions#destroy'
  
  resources :resources
  resources :answers
  resources :books
  resources :chapters
  resources :questions

  match "questions/save_question" => "questions#save_question", :as => :save_question_path

  match "chapters/:id/export" => "chapters#export_to_csv"  
  match "compare_question" => "questions#compare_question"
  match "questions/update_question_scores/:winner_id/:loser_id/:tie" => "questions#update_question_scores"
  match "bandoy_uploader" => "questions#bandoy_uploader"
  match "bandoy_parser" => "questions#bandoy_parser"
  match "examview_uploader" => "questions#examview_uploader"
  match "examview_parser" => "questions#examview_parser"
  match "parse_article/:url" => "resources#parse_article"
  
  #API CALLS
  match "api-V1/get_books/:ids" => "api_v1#get_books"
  match "api-V1/get_book_details/:id" => "api_v1#get_book_details"
  match "api-V1/get_lessons/:ids" => "api_v1#get_lessons"
  match "api-V1/get_all_lesson_questions/:id" => "api_v1#get_questions"
  match "api-V1/get_public" => "api_v1#get_public"
  
  root :to => "static#home"
end
