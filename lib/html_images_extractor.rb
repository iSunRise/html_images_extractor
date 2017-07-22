require 'html_images_extractor/version'
require 'html_images_extractor/html'

module HtmlImagesExtractor
  def self.detect_and_parse(input_file_path)
    raise 'Input file missing' if input_file_path.nil?

    extension = File.extname(input_file_path)
    case extension
    when /\.html/i
      then Html.parse(input_file_path)
    else
      raise 'File extension not html'
    end
  end
end
