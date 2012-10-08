class Country
  include Mongoid::Document
  has_many :cities
  field :name_en, :type     => String
  field :name_ru, :type     => String
  field :code, :type     => String
end
