class Asset
  include Mongoid::Document
  
  field :included, type: Boolean
  field :storage, type: String
  
  belongs_to :post
  belongs_to :user
  belongs_to :asset_collection

  mount_uploader :image, AssetUploader
  
  after_create :cdn_upload
  
  default_scope where(active: true)
  
  def original
    self.image
  end
  
  def thumb
    self.image.md_thumb
  end
  
  private
  
  def cdn_upload
    self.update_atribute :storage, "app"
    Qu.enqueue Reuploaders::Rackspace, self[:_id]
  end
end
