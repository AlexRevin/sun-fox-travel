class Posts::PostItemsController < ApplicationController
  def create
    if (post = Post.find(params[:post_id])).present? && post.user_id == current_user.id
      post_item = post.post_items.find_or_create_by(id: params[:post_item][:_id])
      post_item.update_attributes({
        :text     => params[:post_item][:text],
        :asset_id => params[:post_item][:asset_id],
        :pos      => params[:post_item][:pos]
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
        :pos      => params[:post_item][:pos]
      })
      Asset.find(params[:post_item][:asset_id]).update_attribute :included, true
      
      render :json => {:_id => post_item[:_id], :text => post_item[:text]}
    else
      ap "fail"
      render :status => 500
    end
  end
  
  
  def destroy
    if (post = Post.find(params[:post_id])).present? && post.user_id == current_user.id
      post_item = post.post_items.find(params[:id])
      
      Asset.find(post_item[:asset_id]).update_attribute :included, false
      
      post_item.destroy
      render :text => "ok"
    else
      render :status => 500
    end
  end
end
