require 'nokogiri'
require 'securerandom'
require 'tmpdir'
require 'base64'
require 'phashion'

module HtmlImagesExtractor
  class Html
    class << self
      def parse(input_file_path)
        temp_path = Dir.mktmpdir

        @doc = Nokogiri::HTML(File.open(input_file_path))

        images = @doc.xpath("//img").map do |image_tag|
          image_src = image_tag.values.first.split(',')

          file_name = base64_to_image(image_src, temp_path)
          next if file_name.nil?

          file_path = File.join(temp_path, "#{file_name}")

          id = SecureRandom.random_number(100_000_000)
          image_tag.add_previous_sibling("<!-- image_id: #{id} --->")

          phashion_image = Phashion::Image.new(file_path)
          perceptual_hash = phashion_image.fingerprint

          { file: file_path, hash: perceptual_hash,  id: id }
        end

        { "html": @doc.to_html, "images": images }
      end


      private


      def base64_to_image(image_src, temp_path)
        base_64_encoded_data = image_src.last
        extension = image_src.first.scan(/\/(.*?);/i).flatten.first
        rand_name = SecureRandom.hex

        begin
          base_64_decoded_data = Base64.urlsafe_decode64(base_64_encoded_data)
        rescue ArgumentError => e
          return nil
        end

        Dir.chdir(temp_path) do
          File.open("#{rand_name}.#{extension}", 'wb') do |file|
            file.write(base_64_decoded_data)
          end
        end

        "#{rand_name}.#{extension}"
      end

    end
  end
end
