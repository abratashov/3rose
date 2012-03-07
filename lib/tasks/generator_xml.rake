require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
require 'tools'

desc "generate xml (content of books) for sphinx"
task :gen_sphinx_xml do
  puts "starting generating xml..."
  f = File.new(DIR_XML, 'w+')

  f.syswrite(
%q(<?xml version="1.0" encoding="utf-8"?>
  <sphinx:docset>
  <sphinx:schema>
    <sphinx:field name="content"/>
  </sphinx:schema>) + "\n")
  f.syswrite("\n")
  books = Book.all
  books.each do |b|
    pages = b.pages
    pages.times do |p|
      filename = make_filename_of_txt_page(b.filename, p + 1)
      book_id = b.id*10000 + (p + 1)
      f.syswrite("  <sphinx:document id=" + "\"#{book_id}\"" + ">" + "\n")
      f.syswrite("    <content>" + "\n")
      f.syswrite(IO.read(DIR_TXT_PAGES + filename).delete "<" ">" "&")
      f.syswrite("\n")
      f.syswrite("    </content>" + "\n")
      f.syswrite("  </sphinx:document>" + "\n")
      f.syswrite("\n")
    end
  end

  f.syswrite("</sphinx:docset>")
  f.close
  puts 'complete!'
end

desc "generate xml (content of books) for sphinx"
task :gen_sphinx_xml2 do
  puts "starting generating xml..."
  #arr = [['id1', 'content1'], ['id2', 'content2']]
  arr = []
  books = Book.all
  books.each do |b|
    pages = b.pages
    pages.times do |p|
      filename = make_filename_of_txt_page(b.filename, p+1)
      arr << [filename, IO.read(DIR_TXT_PAGES + filename)]
    end
  end

  builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8')
  builder.docset {
    builder.parent.add_namespace_definition("sphinx","")
    builder['sphinx'].schema {
      builder['sphinx'].field(:name => "content")
    }
    arr.each do |el|
      builder['sphinx'].document(:id => el[0]) do |doc|
        doc.content el[1]
      end
    end
  }
  f = File.new(DIR_XML, 'w+')
  f.syswrite(builder.to_xml)
  f.close
  puts 'complete!'
end