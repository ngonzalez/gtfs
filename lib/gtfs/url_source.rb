require 'net/http'
require 'uri'

module GTFS
  class URLSource < Source

    def load_archive(source_url)
      Dir.mktmpdir do |tmp|
        file_name = File.join(tmp, "/gtfs_temp_#{Time.now.strftime('%Y%jT%H%M%S%z')}.zip")
        uri = URI.parse(source_url)
        response = Net::HTTP.get_response(uri)
        while response.code == '301' || response.code == '302'
          uri = URI.parse(response.header['location'])
          response = Net::HTTP.get_response(uri)
        end
        open(file_name, 'wb') do |file|
          file.write response.body
        end
        extract_to_cache(file_name)
      end
    rescue Exception => e
      raise InvalidSourceException.new(e.message)
    end

  end
end
