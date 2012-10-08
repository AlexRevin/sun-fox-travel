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
