class AssetsController < ApplicationController
  protect_from_forgery :except => [:create]
  
  def create
    ap params
    if Post.find(params[:post_id]).user != current_user
      render :json => "error"
      return
    end
    ac = AssetCollection.where(:post_id => params[:post_id], :user_id => current_user[:_id]).first
    ac = AssetCollection.create(
      :post_id => params[:post_id], 
      :user_id => current_user[:_id]
    ) unless ac.present?
    
    asset = ac.assets.create :image => params[:files].first, :post_id => params[:post_id], :user_id => current_user[:_id], :active => true
    respond_to do |format|
      format.html {
        render :json => asset, :methods => [:thumb, :image]
      }
        
    end
  end
  
  def destroy
    Asset.find(params[:id]).update_attribute :active, false
    render :json => {:text => "ok"}
  end
end
