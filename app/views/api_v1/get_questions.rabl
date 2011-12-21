collection @questions

attributes :id, :question

child(:answers) do
  attributes :id, :answer, :correct
end

node :test do
  "THIS IS TEST TEXT"
end

child(:resources) do
  attributes :url, :contains_answer, :type, :begin, :end
  node :alt_text do
    "this is text"
  end
end