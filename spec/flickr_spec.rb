require "spec_helper"
require_relative "../lib/flickr/flickr_connect"

describe FlickrConnect do
  
  before :all do
    #Load the credentials early on.
    #@credentials = YAML::load(File.open('spec/_secret_config.yml'))
    #@config = YAML::load(File.open('spec/_config.yml'))
    @flick = FlickrConnect.new({})
  end

	it "works" do 
    puts @flick.get_photos
    @flick.write_yaml('_data', 'photos')
  end

end