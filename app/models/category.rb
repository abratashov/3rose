class Category < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Category', :foreign_key => 'parent_id'
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'
  has_many :books#, :class_name => 'Book', :foreign_key => 'category_id'
  validates :name, :presence => true
  validate :parent_id, :if => Proc.new {|p| p.parent_id != p.id}
  validates_uniqueness_of :parent_id, :scope => :name

  #todo: move this logic to js
  def self.generate_list(category = 0)
    @@list = []
    roots = Category.where("parent_id = ?", category)
    roots.each {|root| processtree(root, 0)}
    @@list
  end

  private

  def self.processtree(root, i)
    @@list << {:id => root.id.to_s, :parent_id => root.parent_id.to_s, :name => "#{'--'*i} #{root.name}", :origin_name => root.name}
    if !(root.children.empty?)
      root.children.each {|el| processtree(el, i+1)}
    end
  end

end