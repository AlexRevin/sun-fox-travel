class Post
  include Mongoid::Document
  belongs_to :user
  has_one :asset_collection
  
  field :location_ids, type: Array
  
  embeds_many :post_items
end
