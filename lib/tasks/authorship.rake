task :import => :environment do
  intern_ids = [72, 79, 77, 73, 71, 69, 59, 37, 13, 10]
  public_books = Book.where(:public => true)
  intern_ids.each do |intern_id|
    public_books.each do |book|
      Authorship.create!(:user_id => intern_id, :book_id => book.id)
      puts "created authorship on book #{book.name} for intern ID: #{intern_id}"
    end
  end
end