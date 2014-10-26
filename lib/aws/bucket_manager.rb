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
    begin
      @bucket = @s3.buckets[bucket]
      puts "Successfully connected to #{bucket}"
    rescue => e
      puts "Error, cannot connect to s3 bucket"
      puts $!
      puts e.backtrace
      exit(1)
    end
  end

  def write_file(file)
    if @upload_dir.nil?
      base_name = File.basename(file)
    else
      base_name = file.gsub(@upload_dir+'/','')
    end
    begin
      @bucket.objects[base_name].write(:file => file)
    rescue => e
      puts $!
      puts e.backtrace
    end
  end

  def write_directory(dir_path)
    @upload_dir = dir_path

    files = Dir.glob(dir_path+"/**/*").reject { |file_path| File.directory? file_path }

    count = files.count.to_f

    files.each_with_index do |file, index|
      write_file(file)

      completed_percent = (index.to_f / count)
      completed_int = (completed_percent*30).round

      print "\r"

      completed_int.times do 
        print "*"
      end
      
      (30-completed_int).times do 
        print "."
      end

      print " [#{completed_percent*100}%] "

      $stdout.flush
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