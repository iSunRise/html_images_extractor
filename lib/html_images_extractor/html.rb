require 'nokogiri'
require 'securerandom'
require 'tmpdir'
require 'base64'
require 'phashion'
require 'fastimage'

module HtmlImagesExtractor
  class Html
    class << self
      MIN_IMAGE_WIDTH = 15
      MIN_IMAGE_HEIGHT = 15

      def parse(input_file_path)
        temp_path = Dir.mktmpdir

        @doc = Nokogiri::HTML(File.open(input_file_path))

        images = @doc.xpath("//img").map do |image_tag|
          image_src = image_tag.values.first

          file_name = base64_to_image(image_src, temp_path)
          next if file_name.nil?

          file_path = File.join(temp_path, "#{file_name}")

          id = SecureRandom.random_number(100_000_000)
          image_tag.add_previous_sibling("<!-- image_id: #{id} --->")

          phashion_image = Phashion::Image.new(file_path)
          perceptual_hash = phashion_image.fingerprint

          { file: file_path, hash: perceptual_hash,  id: id }
        end

        { "html": @doc.to_html, "images": images.compact }
      end


      private


      def base64_to_image(image_src, temp_path)
        return nil if image_src.empty?

        width, height = FastImage.size(image_src)
        if width.nil? || height.nil? || (width < MIN_IMAGE_WIDTH && height < MIN_IMAGE_HEIGHT)
          return nil
        end

        information, base_64_encoded_data = image_src.split(',')
        return nil if information.nil? || base_64_encoded_data.nil?

        extension = information.scan(/\/(.*?);/i).flatten.first
        extension.insert(0, '.') if extension
        rand_name = SecureRandom.hex

        begin
          base_64_decoded_data = Base64.urlsafe_decode64(base_64_encoded_data)
        rescue ArgumentError => e
          return nil
        end

        file_name = "#{rand_name}#{extension}"

        Dir.chdir(temp_path) do
          File.open(file_name, 'wb') do |file|
            file.write(base_64_decoded_data)
          end
        end

        file_name
      end

    end
  end
end
