require "spec_helper"

describe GeoJSONWriter do
	before :each do
		@testfile = GeoJSONWriter.new('geojsontestfile')
		@test_hash = {:properties => {:name => 'test'}}
	end

	after :each do
	 	File.delete('geojsontestfile.geojson')
	end
	
	it "Successfully names it appropriately" do
    	@testfile.filename.should == 'geojsontestfile.geojson'
  	end

  	it "Successfully creates file" do
  		expect(File).to exist('geojsontestfile.geojson')
  	end
end