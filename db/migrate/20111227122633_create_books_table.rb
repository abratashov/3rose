class CreateBooksTable < ActiveRecord::Migration
  def up
    create_table :books do |t|
      t.integer :category_id
      t.string :name
      t.string :author
      t.string :filename
      t.text :description

      t.timestamps
    end
  end

  def down
    drop_table :books
  end
end
