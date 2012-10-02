class AssetsController < ApplicationController
  
  def create
    ap current_user.inspect
    if Post.find(params[:post_id]).user != current_user
      render :json => "error"
      return
    end
    ac = AssetCollection.where(:post_id => params[:post_id], :user_id => current_user[:_id]).first
    ac = AssetCollection.create(
      :post_id => params[:post_id], 
      :user_id => current_user[:_id]
    ) unless ac.present?
    
    asset = ac.assets.create :image => params[:files].first, :post_id => params[:post_id], :user_id => current_user[:_id]
    respond_to do |format|
      format.json {
        render :json => asset, :methods => [:thumb, :image]
      }
        
    end
  end
  
  def destroy
    Asset.find(params[:id]).destroy
    render :json => {:text => "ok"}
  end
end
