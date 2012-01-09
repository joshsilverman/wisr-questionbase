object @book

attributes :id, :name

node :icon_url do
    "#{STUDYEGG_STORE_PATH}/assets/eggs/0.png"
end

child @chapters do
  attributes :id, :name, :question_count, :number
end