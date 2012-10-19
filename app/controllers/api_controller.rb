# encoding: utf-8
class ApiController < ActionController::Metal
  include ActionController::Rendering
  include ActionController::Renderers::All
  include ActionController::MimeResponds
  include ActionController::ImplicitRender
  
  respond_to :json
  
  def search
    res = []
    
    # City.where("$or" => [{:name_en => "Tallinn"}, {:name_en => "Narva"}]).all.map(&:name_en)
    
    if params[:q] =~ /[\p{Word}|\d]+/
      q = params[:q].split(" ").join(".*")
      case params[:w]
      when "ctr"
        res |= Country.where(:name_ru => /#{q}/i).desc(:counter).limit(20).all.map{|e| {:id => e[:_id], :name => e[:name_ru]}}
      when "cty"
        res |= City.where(:name_ru => /#{q}/i).limit(20).all.map{|e| {:id => e[:_id], :name => e[:name_ru]}}
        # res |= City.search{keywords params[:q]}.results.map(&:name_ru)
      when "bth"
        # english first
        res |= Country.where(:name_en => /#{q}/i).desc(:counter).limit(5).all.map{|e| {:id => e[:_id], :name => e[:name_ru]}}
        # then russian
        res |= Country.where(:name_ru => /#{q}/i).desc(:counter).limit(5).all.map{|e| {:id => e[:_id], :name => e[:name_ru]}}
        
        #englsh
        res |= City.where(:with_country_en => /#{q}/i).limit(20).all.map{|e| {:id => e[:_id], :name => e[:with_country_en]}}
        # russian
        res |= City.where(:with_country_ru => /#{q}/i).limit(20).all.map{|e| {:id => e[:_id], :name => e[:with_country_ru]}}
        
        res.uniq{|r| r[:_id]}
      end
    end
    respond_with(JSON.generate(res.as_json))
  end
end
