class Book < ActiveRecord::Base
  belongs_to :category

  #define_index do
    #indexes description, :sortable => true
    #indexes description, :match_mode => :boolean
  #end

  #todo: move this logic to js
  def self.generate_list(category = 0)
    list = []
    categories = Category.generate_list(category)
    categories.each do |category|
      book_list = []
      cat_obj = Category.find_by_id(category[:id].to_i)
      unless cat_obj.nil?
        unless cat_obj.books.empty?
          book_list = Book.make_json(cat_obj.books)
          list << {:cat_id => category[:id].to_s, :cat_name => category[:name], :books => book_list}
        end
      end
    end
    list.to_json
  end

  def self.make_json(books)
    list = []
    books.each{|book| list << {:id => book.id.to_s, :author => book.author, :name => book.name, :description => book.description, :filename => book.filename}}
    list
  end
end