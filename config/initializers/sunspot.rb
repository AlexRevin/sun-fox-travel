Sunspot.config.pagination.default_per_page = 24

module MongoidAdapter
  class InstanceAdapter < Sunspot::Adapters::InstanceAdapter
    def id
      @instance.id.to_s
    end
  end

  class DataAccessor < Sunspot::Adapters::DataAccessor
    def load(id)
      @clazz.criteria.for_ids(BSON::ObjectId(id))
    end

    def load_all(ids)
      @clazz.criteria.in(:_id => ids.map {|id| BSON::ObjectId(id)})
    end
  end
end

Sunspot::Adapters::DataAccessor.register(MongoidAdapter::DataAccessor, Mongoid::Document)
Sunspot::Adapters::InstanceAdapter.register(MongoidAdapter::InstanceAdapter, Mongoid::Document)