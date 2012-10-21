class Post
  include Mongoid::Document
  belongs_to :user
  has_one :asset_collection
  
  field :location_ids, type: Array
  
  embeds_many :post_items
  
  def locations
    out = []
    location_ids.each do |_id|
      out << (Country.where(:_id => _id).first() || City.where(:_id => _id).first())
    end if location_ids.present?
    out
  end
  
  def cover_item
    post_items.detect{|pi| pi.cover?} || post_items.first
  end
end
