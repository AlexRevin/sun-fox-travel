class Posts::PostItemsController < ApplicationController
  def create
    if (post = Post.find(params[:post_id])).present? && post.user_id == current_user.id
      post_item = post.post_items.find_or_create_by(id: params[:post_item][:_id])
      post_item.update_attributes({
        :text     => params[:post_item][:text],
        :asset_id => params[:post_item][:asset_id],
        :pos      => (params[:post_item][:pos] || 0),
        :cover    => false,
        :private  => false
      })
      
      Asset.find(params[:post_item][:asset_id]).update_attribute :included, true
      
      render :json => {:_id => post_item[:_id], :text => post_item[:text]}
    else
      render :status => 500
    end
  end
  
  def show
    post_item = Post.find(params[:post_id]).post_items.find(params[:id])
    render :json => {:id => post_item[:id], :text => post_item[:text]}
  end
  
  def update
    if (post = Post.find(params[:post_id])).present? && post.user_id == current_user.id
      post_item = post.post_items.find_or_create_by(:id => params[:post_item][:_id])
      post_item.update_attributes({
        :text     => params[:post_item][:text],
        :asset_id => params[:post_item][:asset_id],
        :pos      => params[:post_item][:pos],
        :private  => params[:post_item][:private]
      })
      
      if params[:post_item][:cover]
        post.post_items.map do |pi|
          pi.update_attribute :cover, false
        end
        post_item.update_attribute :cover, true
      end
      Asset.find(params[:post_item][:asset_id]).update_attribute :included, true
      
      render :json => {:_id => post_item[:_id], :text => post_item[:text], :private => post_item[:private], :cover => post_item[:cover]}
    else
      render :status => 500
    end
  end
  
  
  def destroy
    if (post = Post.find(params[:post_id])).present? && post.user_id == current_user.id
      post_item = post.post_items.find(params[:id])
      
      as = Asset.where(:_id => post_item[:asset_id]).first
      as.update_attribute :included, false if as.present?
      
      post_item.destroy
      render :text => "ok"
    else
      render :status => 500
    end
  end
end
