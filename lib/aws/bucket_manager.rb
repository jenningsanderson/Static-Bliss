require 's3'
require 'aws-sdk'

class BucketManager

  attr_accessor :bucket

  def initialize(access_key_id, secret_access_key)

    @s3 = AWS::S3.new(
                    :access_key_id      => access_key_id,
                    :secret_access_key  => secret_access_key)
  end

  def connect_to_bucket(bucket)
    @bucket = @s3.buckets[bucket]
  end

  def write_file(file)
    if @upload_dir.nil?
      base_name = File.basename(file)
    else
      base_name = file.gsub(@upload_dir+'/','')
    end
    puts @bucket.objects[base_name].write(:file => file)
  end

  def write_directory(dir_path)
    @upload_dir = dir_path

    files = Dir.glob(dir_path+"/**/*").reject { |file_path| File.directory? file_path }

    files.each do |file|
      write_file(file)
    end
  end

  def object_count
    count = 0
    @bucket.objects.each{|obj| count+=1}
    return count
  end

  def empty_bucket
    @bucket.objects.each{|obj| obj.delete}
  end
end