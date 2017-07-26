require 'spec_helper'
require 'html_images_extractor'

require 'pry'

RSpec.describe HtmlImagesExtractor do
  let(:input_file_path) { File.join('spec/fixtures', "#{@file_name}") }
  let(:result_hash) { HtmlImagesExtractor.detect_and_parse(input_file_path) }

  it "returns valid hash with correct attributes" do
    @file_name = 'base64_image.html'
    expect(result_hash[:images][0][:hash]).to eq(15199491225797313363)
  end

  it "returns images array with file attribute without extension" do
    @file_name = 'empty_image_extension.html'
    expect(File.extname(result_hash[:images][0][:file])).to be_empty
    expect(result_hash[:images][0][:hash]).to eq(15199491225797313363)
  end

  it "returns nil in images, if src in img tag in html with external link" do
    @file_name = 'external_link.html'
    expect(result_hash[:images][0]).to be_nil
  end

  it "returns nil in images, if src in img tag in html with invalide base64" do
    @file_name = 'invalide_base64.html'
    expect(result_hash[:images][0]).to be_nil
  end

  it "returns nil in images, if src in img tag in html is empty" do
    @file_name = 'empty_src_img_tag.html'
    expect(result_hash[:images][0]).to be_nil
  end

  it "returns nil in images, if src in img tag in html without base64" do
    @file_name = 'empty_base64.html'
    expect(result_hash[:images][0]).to be_nil
  end
end
