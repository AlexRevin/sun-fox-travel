class PostsController < ApplicationController
  def index
    @posts = Post.where(:user_id => current_user[:_id]).desc(:created_at).all
  end
  
  def edit
    @post = Post.find(params[:id])
    redirect_to :root unless can? :edit, @post
  end
  
  def create
    if post = Post.create(:user => current_user)
      params[:place_ids].split(",").each do |p|
        post.add_to_set(:location_ids, p)
      end if params[:place_ids].present?
      redirect_to edit_post_path(post)
    else
      redirect :back
    end
  end
  
  def update_positions
    if (p=Post.find(params[:id])).user_id == current_user[:_id]
      ps = params[:positions]
      p.post_items.each do |pi|
        i = ps.index{|x| x == pi[:_id].to_s}
        next unless i.present?
        pi.update_attribute :pos, i
      end if ps.present?
      
      render :text => "ok"
    else
      render :status => 404
    end
  end
  
  def show
    @post = Post.find(params[:id])
  end
  
  
  def update
    if (p=Post.find(params[:id])).user_id == current_user[:_id]
      ap params
      p.update_attributes params[:post]
      render :text => "ok"
    else
      render :status => 404
    end
  end
  
  def destroy
    Post.find(params[:id]).destroy
    redirect_to :back
  end
  
  def share
    # render :template => "/modals/share.erb", :layout => false
  end
  
  def set_menu
    @active = :posts
  end
end
