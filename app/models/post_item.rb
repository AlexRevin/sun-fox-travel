class PostItem
  include Mongoid::Document
  
  field :text, type: String
  field :asset_id, type: String
  field :pos, type: Integer
  field :cover, type: Boolean
  field :private, type: Boolean
  
  embedded_in :post
  
  def asset
    Asset.where(:post_id => self.post[:_id], :id => asset_id).first
  end
end
