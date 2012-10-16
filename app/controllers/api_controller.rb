# encoding: utf-8
class ApiController < ActionController::Metal
  include ActionController::Rendering
  include ActionController::Renderers::All
  include ActionController::MimeResponds
  include ActionController::ImplicitRender
  
  respond_to :json
  
  def search
    res = []
    
    if params[:q] =~ /[\p{Word}|\d]+/
      q = params[:q].split(" ").join(".*")
      case params[:w]
      when "ctr"
        res |= Country.where(:name_ru => /#{q}/i).desc(:counter).limit(20).all.map{|e| {:id => e[:_id], :name => e[:name_ru]}}
        # res |= Country.search{keywords params[:q]}.results.map(&:name_ru)
      when "cty"
        res |= City.where(:name_ru => /#{q}/i).limit(20).all.map{|e| {:id => e[:_id], :name => e[:name_ru]}}
        # res |= City.search{keywords params[:q]}.results.map(&:name_ru)
      when "bth"
        res |= Country.where(:name_ru => /#{q}/i).desc(:counter).limit(5).all.map{|e| {:id => e[:_id], :name => e[:name_ru]}}
        res |= City.where(:with_country_ru => /#{q}/i).limit(20).all.map{|e| {:id => e[:_id], :name => "#{e[:with_country_ru]}"}}
        # res |= Sunspot.search(City, Country) {
        #   fulltext params[:q] do
        #     boost_fields :country_ru => 2.0
        #   end
        # }.results.map{|r| r.is_a?(Country) ? "#{r.name_ru}" : "#{r.country.name_ru}, #{r.name_ru}"}
      end
    end
    respond_with(JSON.generate(res.as_json))
  end
end
