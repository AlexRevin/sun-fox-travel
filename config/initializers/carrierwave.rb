module CarrierWave
  # module RMagick
  # 
  #   # Rotates the image based on the EXIF Orientation
  #   def fix_exif_rotation
  #     manipulate! do |img|
  #       img.auto_orient!
  #       img = yield(img) if block_given?
  #       img
  #     end
  #   end
  # 
  #   # Strips out all embedded information from the image
  #   def strip
  #     manipulate! do |img|
  #       img.strip!
  #       img = yield(img) if block_given?
  #       img
  #     end
  #   end
  # 
  #   # Reduces the quality of the image to the percentage given
  #   def quality(percentage)
  #     manipulate! do |img|
  #       img.write(current_path){ self.quality = percentage }
  #       img = yield(img) if block_given?
  #       img
  #     end
  #   end
  # 
  # end
  
  
  module MiniMagick
    
    def autorotate
      manipulate! do |image|
        image.auto_orient
        image
      end
    end
    
    def toaster_filter
      manipulate! do |img|
        img.modulate '150,80,100'
        img.gamma "1.1"
        img.contrast
        img.contrast
        img.contrast
        img.contrast

        img = yield(img) if block_given?
        img
      end
    end
    
    
    def light_blur(lvl, pc)
      manipulate! do |img|
        Rails.logger.debug img.inspect
        img.combine_options do |cmd|
          cmd.blur lvl
          cmd.quality pc
          cmd.colorspace "Gray"
          cmd.gamma "0.8"
        end
        
        sp_img = ::MiniMagick::Image.open("#{Rails.root}/app/assets/images/spinner.png")

        img = img.composite(sp_img) do |cmd|
          cmd.gravity 'center'
        end
        
        img = yield(img) if block_given?
        img
      end
    end

    def lomo_filter
      manipulate! do |img|
        img.channel 'R'
        img.level '22%'
        img.channel 'G'
        img.level '22%'

        img = yield(img) if block_given?
        img
      end
    end

    def kelvin_filter
      manipulate! do |img|
        cols, rows = img[:dimensions]

        img.combine_options do |cmd|
          cmd.auto_gamma
          cmd.modulate '120,50,100'
        end

        new_img = img.clone
        new_img.combine_options do |cmd|
          cmd.fill 'rgba(255,153,0,0.5)'
          cmd.draw "rectangle 0,0 #{cols},#{rows}"
        end

        img = img.composite new_img do |cmd|
          cmd.compose 'multiply'
        end

        img = yield(img) if block_given?
        img
      end
    end

    def colortone_filter(color = '#222b6d', level = 100, type = 0)
      manipulate! do |img|
        color_img = img.clone
        color_img.combine_options do |cmd|
          cmd.fill color
          cmd.colorize '63%'
        end

        img = img.composite color_img do |cmd|
          cmd.compose 'blend'
          cmd.define "compose:args=#{level},#{100-level}"
        end

        img = yield(img) if block_given?
        img
      end
    end

    def gotham_filter
      manipulate! do |img|
        img.modulate '120,10,100'
        img.fill '#222b6d'
        img.colorize "20"
        img.gamma "0.5"
        img.contrast

        img = yield(img) if block_given?
        img
      end
    end

    def strip
      manipulate! do |img|
        img.strip

        img = yield(img) if block_given?
        img
      end
    end

    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage)

        img = yield(img) if block_given?
        img
      end
    end

    def vignette(path_to_file)
      manipulate! do |img|
        cols, rows = img[:dimensions]

        vignette_img = ::MiniMagick::Image.open(path_to_file)
        vignette_img.size "#{cols}x#{rows}"

        img = img.composite(vignette_img) do |cmd|
          cmd.gravity 'center'
          cmd.compose 'multiply'
        end

        img = yield(img) if block_given?
        img
      end
    end

    def pad_it_up(width, height, background=:transparent, gravity='Center')
      manipulate! do |img|
        cols, rows = img[:dimensions]

        if width > cols || height > rows
          img.combine_options do |cmd|
            if background == :transparent
              cmd.background "rgba(255, 255, 255, 0.0)"
            else
              cmd.background background
            end
            cmd.gravity gravity
            if width > cols && height > rows
              cmd.extent "#{width}x#{height}"
            elsif width > cols
              cmd.extent "#{width}x#{rows}"
            else
              cmd.extent "#{cols}x#{height}"
            end
          end
        end

        img = yield(img) if block_given?
        img
      end
    end
  end
  
end

CarrierWave.configure do |cfg|
  cfg.asset_host = proc do |file|
    if Rails.env.production?
      "http://cdn#{rand(1..3)}.sunfoxtravel.ru"
    else
      "http://sft.assets:3100"
    end
  end
  
  # cfg.fog_credentials = {
  #   :provider           => 'Rackspace',
  #   :rackspace_username => 'at0mic',
  #   :rackspace_api_key  => '316878bfef5241e24c21fa61ccb880dd'
  # }
  # cfg.fog_directory = 'cdn1'
  # cfg.fog_host = "http://cdn1.sunfoxtravel.ru"
end