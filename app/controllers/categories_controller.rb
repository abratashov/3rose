class CategoriesController < ApplicationController
  layout 'application'

  def get_list
    render :json => Category.generate_list.to_json
  end

   def add
     p ">>>>>>>>>>>>>>>>>>>>>>>>> add"
     category = Category.new(
       :parent_id => params[:parent_id].to_i,
       :name => params[:name]
     )
     category.save
     p category.inspect
     render :nothing => true, :status => 200 and return
   end

   def delete
   end

   def update
   end

   def search
     render
   end
end