OauthClientDemo::Application.routes.draw do
  resources :authorships

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  match "users/sign_up" => redirect("/")

  devise_for :users

  # omniauth
  match '/auth/:provider/callback', :to => 'user_sessions#create'
  match '/auth/failure', :to => 'user_sessions#failure'

  #BOOKS
  match "books/get_next_chapter_number" => "books#get_next_chapter_number"

  #CHAPTERS
  match "chapters/update_status" => "chapters#update_status"
  match "chapters/publish" => "chapters#publish"
  match "chapters/add" => "chapters#add"

  #QUESTIONS
  match "questions/save_question" => "questions#save_question", :as => :save_question_path
  match "compare_question" => "questions#compare_question"
  match "questions/update_question_scores/:winner_id/:loser_id/:tie" => "questions#update_question_scores"
  match "questions/get_permission" => "questions#get_permission"

  #RESOURCES
  match "parse_article" => "resources#parse_article"
  match "search_videos" => "resources#search_videos"
  
  #KEYWORDS
  match "keywords/get_matching_keywords" => "keywords#get_matching_keywords"
  match "keywords/add_keyword" => "keywords#add_keyword"
  match "keywords/get_keywords" => "keywords#get_keywords"
  match "keywords/remove_keyword" => "keywords#remove_keyword"
  match "keywords/get_questions_keywords" => "keywords#get_questions_keywords"

  #EXPORT
  match "chapters/:id/export" => "chapters#export_to_csv"  

  #UPLOADER
  match "bandoy_uploader" => "questions#bandoy_uploader"
  match "bandoy_parser" => "questions#bandoy_parser"
  match "examview_uploader" => "questions#examview_uploader"
  match "examview_parser" => "questions#examview_parser"
    
  #API CALLS
  match "api-V1/:api_key/get_books/:ids" => "api_v1#get_books"
  match "api-V1/:api_key/get_book_details/:id" => "api_v1#get_book_details"
  match "api-V1/:api_key/get_book_by_chapter_id/:id" => "api_v1#get_book_by_chapter_id"
  match "api-V1/:api_key/get_lessons/:ids" => "api_v1#get_lessons"
  match "api-V1/:api_key/get_all_lesson_questions/:id" => "api_v1#get_all_questions"
  match "api-V1/:api_key/get_lesson_questions/:ids" => "api_v1#get_questions"
  match "api-V1/:api_key/get_questions/:ids" => "api_v1#get_questions"
  match "api-V1/:api_key/get_public" => "api_v1#get_public"
  match "api-V1/:api_key/get_public_with_lessons" => "api_v1#get_public_with_lessons"
  match "api-V1/:api_key/get_lesson_details/:ids" => "api_v1#get_lesson_details"
  match "api-V1/:api_key/get_questions_topics/:question_ids" => "api_v1#get_questions_topics"
  match "api-V1/:api_key/get_question_count/:chapter_id" => "api_v1#get_question_count"
  match "api-V1/:api_key/get_all_question_ids_from_lesson/:id" => "api_v1#get_all_question_ids_from_lesson"
  match "api-V1/:api_key/get_book_id_by_chapter_id/:id" => "api_v1#get_book_id_by_chapter_id"

  resources :keywords
  resources :resources
  resources :answers
  resources :books
  resources :chapters
  resources :questions
   
  root :to => "books#index"
end
