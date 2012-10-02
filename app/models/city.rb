class City
  include Mongoid::Document
  belongs_to :country
  
  field :name_en, :type     => String
  field :name_ru, :type     => String
  field :postal_code, :type => String
  field :region, :type      => String
  field :latitude, :type    => String
  field :longitude, :type   => String

  include Sunspot::Mongoid
  searchable do
     text :name_en, :as => :code_textp
     text :name_ru, :as => :code_textp
     text :country_en, :as =>:code_textp do
       country.name_en
     end
     text :country_ru, :as =>:code_textp do
       country.name_ru
     end
   end
end
