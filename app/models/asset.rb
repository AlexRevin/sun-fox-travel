class Asset
  include Mongoid::Document
  
  field :included, type: Boolean
  
  belongs_to :post
  belongs_to :user
  belongs_to :asset_collection

  mount_uploader :image, AssetUploader
  
  default_scope where(active: true)
  
  def original
    self.image
  end
  
  def thumb
    self.image.md_thumb
  end
end
