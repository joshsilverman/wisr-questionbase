object @lesson

attributes :name, :media_url

node :book_name do
    @book_name
end

child(:questions) do
  	attributes :id, :question, :correct
	
	child(:answers) do
	  attributes :id, :answer, :correct
	end

	child(:resources) do
	  attributes :url, :contains_answer, :media_type, :begin, :end
	end
end