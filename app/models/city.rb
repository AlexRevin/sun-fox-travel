class City
  include Mongoid::Document
  belongs_to :country
  
  field :name_en, :type         => String
  field :name_ru, :type         => String
  field :postal_code, :type     => String
  field :region, :type          => String
  field :latitude, :type        => String
  field :longitude, :type       => String
  field :with_country_ru, :type => String

end
