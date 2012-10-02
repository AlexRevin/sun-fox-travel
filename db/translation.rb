table "net_country" do
  column "id", :key
  column "name_ru", :string
  column "name_en", :string
  column "code", :string
end

table "net_city" do
  column "id", :key
  column "country_id", :integer, :references => :net_country
  column "name_ru", :string
  column "name_en", :string
  column "region", :string
  column "postal_code", :string
  column "latitude", :string
  column "longitude", :string
end
