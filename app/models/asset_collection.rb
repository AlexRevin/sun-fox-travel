class AssetCollection
  include Mongoid::Document
  
  has_many :assets
  belongs_to :user
  belongs_to :post
end
