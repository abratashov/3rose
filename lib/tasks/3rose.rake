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

desc "generate all need directories"
task :gen_directories do
  if !(Dir.exist?(DIR_SPHINX))
    Dir.mkdir(DIR_SPHINX)
  end
  if !(Dir.exist?(DIR_UPLOADS))
    Dir.mkdir(DIR_UPLOADS)
  end
  if !(Dir.exist?(DIR_BOOK))
    Dir.mkdir(DIR_BOOK)
  end
  if !(Dir.exist?(DIR_IMG))
    Dir.mkdir(DIR_IMG)
  end
  if !(Dir.exist?(DIR_PDF))
    Dir.mkdir(DIR_PDF)
  end
  if !(Dir.exist?(DIR_TXT_PAGES))
    Dir.mkdir(DIR_TXT_PAGES)
  end
end
