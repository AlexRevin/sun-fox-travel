class PostsController < ApplicationController
  def index
    @posts = Post.where(:user_id => current_user[:_id]).all
  end
  
  def edit
    @post = Post.find(params[:id])
  end
  
  def create
    city = City.where(:name_ru => params[:city]).first
    country = Country.where(:name_ru => params[:country]).first
    
    if post = Post.create(:city => city, :country => country, :user => current_user)
      redirect_to edit_post_path(post)
    else
      redirect :back
    end
  end
  
  def update_positions
    if (p=Post.find(params[:id])).user_id == current_user[:_id]
      ps = params[:positions]
      p.post_items.each do |pi|
        pi.update_attribute :pos, ps.index{|x| x == pi[:_id].to_s}
      end
      
      render :text => "ok"
    else
      render :status => 404
    end
  end
  
  def show
    @post = Post.find(params[:id])
  end
  
  
  def update

  end
  
  def destroy
    Post.find(params[:id]).destroy
    redirect_to :back
  end
  
  def set_menu
    @active = :posts
  end
end
