namespace :sunspot do 
  desc "indexes searchable models" 
  task :index => :environment do 
    [City, Country].each {|model| Sunspot.index!(model.all)} 
  end 
end