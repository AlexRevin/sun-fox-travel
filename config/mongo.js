// countries sorting
db.countries.find().forEach( function(c) { 
  print("cities: " + db.cities.find({'country_id' : c._id}).count());
  print("country: " + c.name_ru);
  c.counter = db.cities.find({'country_id' : c._id}).count();
  db.countries.save(c);
});


// optimizing search
db.cities.find().forEach(function(c){
  cn = db.countries.findOne({'_id' : c.country_id});
  if (cn == null) {
    db.cities.remove(c)    
  } else {
    if (cn.code == "US"){
      c.with_country_ru = cn.name_ru + ", " + c.region + ", "+ c.name_ru
      c.with_country_en = cn.name_en + ", " + c.region + ", "+ c.name_en
    } else {
      c.with_country_ru = cn.name_ru + ", " + c.name_ru
      c.with_country_en = cn.name_en + ", " + c.name_en
    }
    db.cities.save(c)    
  }
})


// removing dupes
// too slow yet
db.cities.find().forEach(function(c){
  count = db.cities.find({'name_en': c.name_en, 'country_id': c.country_id, 'region': c.region, "latitude" : c.latitude, "longitude": c.longitude}).count()
  if ( count > 1) {
    var i = 0;
    db.cities.find({'name_en': c.name_en, 'country_id': c.country_id, 'region': c.region, "latitude" : c.latitude, "longitude": c.longitude}).forEach(function(clone){
      if (i > 0) {
        i++;
        db.cities.remove(clone)
      }
    })
    print("city: " + c.name_ru + ", count: " + count)
  }
})