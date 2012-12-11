class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user
  has_one :asset_collection
  
  field :title, type: String
  field :location_ids, type: Array
  field :published, type: Boolean, :default => false
  
  embeds_many :post_items do
    
    def public
      where(private: false)
    end
    
    def private
      where(private: true)
    end
  end
  
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
