class Country
  include Mongoid::Document
  has_many :cities
  field :name_en, :type     => String
  field :name_ru, :type     => String
  field :code, :type     => String

  include Sunspot::Mongoid
  searchable do
     text :name_en, :as => :code_textp
     text :name_ru, :as => :code_textp
   end
end
