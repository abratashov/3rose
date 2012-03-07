# -*- encoding : utf-8 -*-
require 'carrierwave'
require 'tools'
require 'docsplit'
require 'riddle'
require 'riddle/0.9.9'

class BooksController < ApplicationController
  layout 'application'

  def get_list
    render :json => Book.generate_list(params[:category])
  end

  def get_origin_file
    book = Book.find_by_id(params[:book_id])
    if book
      uploader = BookUploader.new
      uploader.retrieve_from_store!(book.filename)
      uploader.cache_stored_file!
      send_file uploader.file.path
    else
      render :text => 'error: book not found'
    end
  end

  def get_book_info
    book = Book.find_by_id(params[:book_id])
    if book
      render :json => book.to_json
    else
      render :text => 'error: book not found'
    end
  end

  def get_page
    p "============================================================================ get"

    book = Book.find_by_id(params[:book_id])
    if book
      new_file = make_filename_of_txt_page(book.filename, params[:page_num])
      textpage = ''
      new_file = DIR_TXT_PAGES + new_file
      if FileTest.exist?(new_file)
        textpage = IO.readlines(new_file).join('<br>')
      end
      render :text => textpage
    else
      render :text => 'error: book not found'
    end
  end

   def add
     p "============================================================================ add"
     p '#=====================1 save to DIR_BOOK (use carrierwave)'
     book = Book.new(
       :category_id => params[:book_category],
       :author => params[:author],
       :name => params[:name],
       :description => params[:description]
     )
     filename = make_filename(book.author, book.name, params[:book_file].original_filename)
     params[:book_file].original_filename = filename
     uploader = BookUploader.new
     uploader.store!(params[:book_file])
     book.filename = filename
     p filename
     
     p '#2===================== convert document to pdf (use Docsplit)'
     #uploader = BookUploader.new
     #uploader.retrieve_from_store!(book.filename)
     #uploader.cache_stored_file!
     #path = uploader.file.path
     Docsplit.extract_pdf(DIR_BOOK + book.filename, :output => DIR_PDF)
     p '#3===================== erase text pages from pdf (use PdfUtils)'
     #uploader = BookUploader.new
     #uploader.retrieve_from_store!('en_-_en.pdf')
     #uploader.cache_stored_file!
     #path = uploader.file.path
     #p path
     #results = PdfUtils::extract_pages(path)
     #!!name = make_pdf_name (book.filename)
     pdf_name = make_need_filename_extension(book.filename, 'pdf')
     num_pages = PdfUtils.info(DIR_PDF + pdf_name).pages
     book.pages = num_pages
     ppp = DIR_PDF + pdf_name
     p ppp
     ppp = DIR_TXT_PAGES
     p ppp
     Docsplit::extract_text(DIR_PDF + pdf_name, :ocr => false, :pages => 'all', :output => DIR_TXT_PAGES)
     delete_last_byte_at_files(book.filename, num_pages)
     #4===================== create xml
     #5===================== add new index
     #results = %x[search далай]
     #results = Sphinx::Client.new.query('test')
     #6===================== index search by riddle
     #client = Riddle::Client.new
     #results = client.query('далай') #[id_doc1,...]
     book.save
     redirect_to :root
   end

   def delete
   end

   def update
     p '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> update'
     #results = %x[search далай]
     #results = Sphinx::Client.new.query('test')

     #1 index search by riddle
     #client = Riddle::Client.new
     #results = client.query('далай') #[id_doc1,...]

     #2
     uploader = BookUploader.new
     uploader.retrieve_from_store!('en_-_en.doc')
     uploader.cache_stored_file!
     path = uploader.file.path
     p path
     result = Docsplit.extract_pdf(path)

     #3 split pdf to pages
     #uploader = BookUploader.new
     uploader.retrieve_from_store!('en_-_en.pdf')
     uploader.cache_stored_file!
     path = uploader.file.path
     #p path
     #results = PdfUtils::extract_pages(path)
     results = Docsplit::extract(path)
     p results
     render :json => results.to_json
   end

   def search
     render
   end

   def search_by_name
     result = []
     search_string = params[:search]
     if search_string
       books = Book.find(:all)
       books.each do |book|
         if !(book.name.mb_chars.downcase.to_s.match(/#{search_string.mb_chars.downcase.to_s}/).nil?) ||
           !(book.author.mb_chars.downcase.to_s.match(/#{search_string.mb_chars.downcase.to_s}/).nil?) #need optimization - add sql index
           result << {:obj => book, :pages => []}
         end
       end
     end
     render :json => result.to_json
   end
   
   def search_by_content
     result = []
     search_string = params[:search]
     if search_string
       books_pages = {}
       sphinx = Riddle::Client.new
       sphinx.limit = 50
       sphinx_results = sphinx.query(params[:search])
       sphinx_results[:matches].each do |match|
         id = (match[:doc]/10000).to_i
         if !(books_pages[id])
           books_pages[id] = []
         end
         books_pages[id] << (match[:doc] - ((match[:doc]/10000).to_i)*10000)
       end
       p books_pages
       books_pages.each do |key, value|
         result << {:obj => Book.find(key), :pages => value}
       end
     end
     render :json => result.to_json
   end
end