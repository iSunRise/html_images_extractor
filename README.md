# HtmlImagesExtractor

HtmlImagesExtractor gem used to parse html file to find all images in base64, returns hash, which include html with image_ids in comments previous image tag and array with hashes, which include: image path, perceptual hash and id.  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'html_images_extractor'
```

## Usage

HtmlImagesExtractor.detect_and_parse(input_file_path_with_html_extension)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
