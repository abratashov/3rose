# -*- encoding : utf-8 -*-

#todo: bring out to JS!!! - generating file name
def cyrillic_to_latin(str)
  table = {
    'а' => 'a', 'А' => 'A',
    'б' => 'b', 'Б' => 'B',
    'в' => 'v', 'В' => 'V',
    'г' => 'g', 'Г' => 'G',
    'д' => 'd', 'Д' => 'D',
    'е' => 'e', 'Е' => 'E',
    'ё' => 'yo', 'Ё' => 'Yo',
    'ж' => 'zh', 'Ж' => 'Zh',
    'з' => 'z', 'З' => 'Z',
    'и' => 'i', 'И' => 'I',
    'й' => 'y', 'Й' => 'Y',
    'к' => 'k', 'К' => 'K',
    'л' => 'l', 'Л' => 'L',
    'м' => 'm', 'М' => 'M',
    'н' => 'n', 'Н' => 'N',
    'о' => 'o', 'О' => 'O',
    'п' => 'p', 'П' => 'P',
    'р' => 'r', 'Р' => 'R',
    'с' => 's', 'С' => 'S',
    'т' => 't', 'Т' => 'T',
    'у' => 'u', 'У' => 'U',
    'ф' => 'f', 'Ф' => 'F',
    'х' => 'h', 'Х' => 'H',
    'ц' => 'ts', 'Ц' => 'Ts',
    'ч' => 'ch', 'Ч' => 'Ch',
    'ш' => 'sh', 'Ш' => 'Sh',
    'щ' => 'sch', 'Щ' => 'Sch',
    'ъ' => '',  'Ъ' => '',
    'ы' => 'u', 'Ы' => 'U',
    #'ь' => "\'", 'Ь' => "\'",
    'ь' => "", 'Ь' => "",
    'э' => 'e', 'Э' => 'E',
    'ю' => 'ju', 'Ю' => 'Yu',
    'я' => 'ja', 'Я' => 'Ya',
    'є' => 'ye', 'Є' => 'Ye',
    'і' => 'i', 'І' => 'I',
    'ї' => 'yi', 'Ї' => 'Yi'
  }
  newstr = ''
  str.each_char {|char| newstr += table[char] ? table[char] : char}
  newstr.split(' ').join('_')
end

def make_filename(author, name, old_filename)
  ext = old_filename.gsub(/^.*\./,'')
  filename = author + ' - ' + name + '.' + ext
  cyrillic_to_latin(filename).downcase
end

def make_need_filename_extension(old_filename, new_ext)
  p  '>>>>>>>>>>>>>>>>>>>>>>> make_need_filename_extension'
  p old_filename
  filename = old_filename.gsub(/\..*$/,'')
  p filename
  new_filename = filename + '.' + new_ext
  p new_filename
  new_filename
end

def make_filename_of_txt_page(old_filename, page)
  p  '>>>>>>>>>>>>>>>>>>>>>>> make_filename_of_txt_page'
  p old_filename
  filename = old_filename.gsub(/\..*$/,'')
  p filename
  new_filename = filename + '_' + page.to_s + '.' + 'txt'
  p new_filename
  new_filename
end

def delete_last_byte_at_files(filename, num_pages)
  num_pages.to_i.times do |page|
    filename_page = make_filename_of_txt_page(filename, page + 1)
    file = File.new(DIR_TXT_PAGES + filename_page, 'a+')
    if (file.size > 0)
      file.seek(file.size - 1)
      last_byte = file.getc
      if last_byte == "\f"
        file.truncate(file.size - 1)
      end
    end
    file.close
  end
end
