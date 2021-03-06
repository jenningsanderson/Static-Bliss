# This part of the gem will connect to a Flickr Set and write a YAML file
# to be parsed by Jekyll
# 
# Original Author of Flickr Set Plugin: Thomas Mango (thomasmango.com)
# 
require 'net/https'
require 'uri'
require 'json'


#This is designed to write a YAML file for each set.
class FlickrConnect
	attr_reader :config

	def initialize(config)
		@config = config
		

		@config['gallery_tag']   ||= 'div'
		@config['gallery_class'] ||= 'gallery'
		@config['a_href']        ||= nil
		@config['a_target']      ||= '_blank'
		@config['image_rel']     ||= ''
		@config['thumbnail_size']||= 's'

		@set = @config[:set]

		@photos = [] #The empty array to be filled...

	end


	#Thomas Mango's code:
	def get_photos
		JSON.parse(json_response)['photoset']['photo'].each do |item|
			@photos << FlickrPhoto.new(item['title'], item['id'], item['secret'], item['server'], item['farm'], item['tags'], item['description'], @config['thumnail_size'], item['url_o'])
      	end
    end

	def json_response
		uri  = URI.parse("https://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&photoset_id=#{@set}&api_key=#{@config[:api_key]}&format=json&nojsoncallback=1&extras=tags,description,url_o")
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		return http.request(Net::HTTP::Get.new(uri.request_uri)).body
	end

	def photos
		@photos_sorted_by_tag = {}

		@photos.collect{|pic| pic.tags}.flatten.uniq.each do |tag|
			puts "Searching for #{tag}"
			@photos_sorted_by_tag[tag] = 
				@photos.select{|pic| pic.tags.include? tag}
		end
		@photos_sorted_by_tag
	end
end

#Also from Thomas Mango
class FlickrPhoto
	attr_reader :title, :tags, :link, :description

	def initialize(title, id, secret, server, farm, tags, description, thumbnail_size, original_url)
		@title          = title
		@url            = "http://farm#{farm}.staticflickr.com/#{server}/#{id}_#{secret}.jpg"
		@thumbnail_url  = url.gsub(/\.jpg/i, "_#{thumbnail_size}.jpg")
		@tags = tags.split
		@link = "http://www.google.com"
		@o_url = original_url
	
		process_description(description['_content'])
	end

	def process_description(desc)
		begin
			desc_tags = desc.scan(/\[(.*)\]/).flatten[0]
			@tags +=  desc_tags.split(',').collect{|x| x.strip}
		rescue => e
			puts "An error occured parsing the tags in the description"
			puts e.backtrace
		end
		@description = desc[0..desc.index('[')-1].strip
	end

	def url(size_override = nil)
		return (size_override ? @thumbnail_url.gsub(/_#{@thumbnail_size}.jpg/i, "_#{size_override}.jpg") : @url)
	end

	def thumbnail_url
		return @thumbnail_url
	end

	def <=>(photo)
		@title <=> photo.title
	end
end