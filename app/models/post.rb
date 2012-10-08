class Post
  include Mongoid::Document
  belongs_to :user
  has_one :asset_collection
  belongs_to :city
  belongs_to :country
  
  embeds_many :post_items
  
end
