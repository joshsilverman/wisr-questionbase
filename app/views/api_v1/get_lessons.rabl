collection @books

attributes :id, :name

node :icon_url do
  "#{STUDYEGG_STORE_PATH}/assets/eggs/0.png"
end


child(:chapters) do
  attributes :id, :name
end

# child :chapters do
#   attributes :id, :name
# end