require 'rubygems'
require 'aws/s3'
require 'fileutils'

'''
Some data taken From: https://gist.github.com/digitalsanctum/643716
'''

ACCESS_KEY_ID = "AKIAJ7UP7VZ3XEYHOBMQ"
SECRET_ACCESS_KEY = "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"

UPLOAD_DIR = "/Users/jenningsanderson/Dropbox/jekyll/epic/_site"
BUCKET = "epic.cs.colorado.edu"
KEY_PREFIX = ""

mime_types = Hash.new()
mime_types = {:css => 'text/css'}

class Upload
  def initialize
    AWS::S3::Base.establish_connection!(
      :access_key_id => ACCESS_KEY_ID,
      :secret_access_key => SECRET_ACCESS_KEY
    )
  end

  def put(local_file)
    base_name = local_file.gsub(UPLOAD_DIR+'/','')
    #mime_type = mime_type(local_file)

    puts "Writing #{base_name}"

    AWS::S3::S3Object.store(
      "#{KEY_PREFIX}#{base_name}",
      File.open(local_file),
      BUCKET,
      :access => :public_read
    )
    puts "Upload completed"
  end

  def mime_type(f)
    mimetype = `file --mime-type --brief #{f}`
  end
end

files = Dir.glob(UPLOAD_DIR+"/**/*").reject { |file_path| File.directory? file_path }

uploader = Upload.new()

puts "Beginning upload"

files.each do |f|
  uploader.put(f)
end
