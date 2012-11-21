# Reuploaders::Rackspace
module Reuploaders
  class Rackspace
    attr_accessor :opts, :asset, :image, :fog, :directory

    def self.perform asset_id
      asset = Asset.find(asset_id)
      rs = self.new asset, :with_original => true, :truncate_after => true
      rs.upload_all
      asset.update_attribute :storage, "cdn"
    end
    
    def initialize(asset, *args)
      @opts = args.extract_options!
      @asset = asset
      @image = asset.image
      @store_dir = @image.store_dir
      
      @@settings ||= (lambda{
        f = File.read("#{Rails.root}/config/rackspace.yml")
        HashWithIndifferentAccess.new(YAML::load(f))
      }.call())
      
      conn_settings = @@settings.clone.merge(:provider => "Rackspace")
      cwd = conn_settings.delete(:rackspace_directory)
      @fog = Fog::Storage.new(conn_settings)
      @directory = @fog.directories.get(cwd)
    end
    
    def directory_each_file
      return unless block_given?
      @directory.files.each do |rs_file|
        yield rs_file
      end
    end
    
    def path_to(filename)
      "#{@store_dir}/#{filename}"
    end
    
    def upload_all
      version_objects.each do |version|
        filename = version.send(:full_filename, @asset.image_filename)
        store :filename => path_to(filename), :file_stream => version.read        
        File.unlink version.path if @opts[:truncate_after]
      end
      if @opts[:with_original]
        store :filename => path_to(@asset.image_filename), :file_stream => @image.read
        File.unlink @image.path if @opts[:truncate_after]
      end
    end
    
    def store *args
      opts = args.extract_options!
      file = directory.files.create(
        :key    => opts[:filename],
        :body   => opts[:file_stream],
        :public => true
      )
      yield file if block_given?
    end
    
    def versions
      @image.versions.keys
    end
    
    def version_objects
      @image.versions.keys.map{|v| @image.send(v)}
    end
  end
end