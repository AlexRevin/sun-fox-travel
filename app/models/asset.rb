class Asset
  include Mongoid::Document
  
  belongs_to :post
  belongs_to :user
  belongs_to :asset_collection

  mount_uploader :image, AssetUploader
  
  def original
    self.image
  end
  
  def thumb
    self.image.md_thumb
  end
end
