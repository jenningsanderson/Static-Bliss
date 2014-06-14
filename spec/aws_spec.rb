require "spec_helper"

describe BucketManager do
  before :all do
    @credentials = YAML::load(File.open('spec/_secret_config.yml'))
    @config = YAML::load(File.open('spec/_config.yml'))
  end

  before :each do
    #Authenticate to the bucket
    @manager = BucketManager.new(@credentials['s3_id'], @credentials['s3_secret'])
    @manager.connect_to_bucket(@credentials['production_bucket'])
	end

	it "Can access contents of bucket" do
    count = @manager.object_count
    count.should >= 0
	end

  it "Can write a file" do
    count = @manager.object_count
    @manager.write_file('/Users/jenningsanderson/Desktop/janis_wedding.jpg')
    @manager.object_count.should == count+1
  end

  it "Can write a directory" do
    count = @manager.object_count
    @manager.write_directory('/Users/jenningsanderson/Desktop/test')
    @manager.object_count.should > count
  end

  it "Can empty a bucket" do 
    @manager.empty_bucket
    @manager.object_count.should == 0
  end
end