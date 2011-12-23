object @book

attributes :id, :name

node :icon_url do
    "http://localhost:3002/assets/eggs/0.png"
end

child :chapters do
  attributes :id, :name, :question_count
end