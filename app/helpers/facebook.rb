class Facebook
  require 'net/http'
  require 'uri'
  @@access_token = nil
  @@access_token_expiry = nil

  def self.GetAccessToken
    if @@access_token.nil? or @@access_token_expiry.nil? or Time.now.to_i - @@access_token_expiry.to_i > (60*45)
      url = URI.parse('https://graph.facebook.com/oauth/access_token?client_id=621440944588767&client_secret=9bcad7af475da5c81d61f58f2b13075d&grant_type=client_credentials')
      http = Net::HTTP.new url.host, url.port
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
      response = http.request(Net::HTTP::Get.new(url.request_uri))
      @@access_token = response.body
      @@access_token_expiry = Time.now
    end
    return @@access_token
  end

  def self.GetNewsFeed
    new_uri = URI.encode('https://graph.facebook.com/TheStagingGuyAustin/feed?' + self.GetAccessToken)
    url = URI.parse(new_uri)
    http = Net::HTTP.new url.host, url.port
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.use_ssl = true
    response = http.request(Net::HTTP::Get.new(url.request_uri))
    return JSON.parse(response.body)

  end

  def self.GetPosts
    jsonHash = self.GetNewsFeed
    return jsonHash['data']
  end

  def self.formatDate(inputTime)
    require 'active_support/core_ext/integer/inflections'
    the_time = inputTime.to_time
    return the_time.strftime("%B %d")
  end

  def self.GetLatestPhotos
    new_uri = URI.encode('https://graph.facebook.com/TheStagingGuyAustin/albums?' + self.GetAccessToken)
    url = URI.parse(new_uri)
    http = Net::HTTP.new url.host, url.port
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.use_ssl = true
    response = http.request(Net::HTTP::Get.new(url.request_uri))
    jsonHash = JSON.parse(response.body)
    album_list = jsonHash['data']

    forbidden_albums = ['Timeline Photos', 'Profile Pictures']
    latest_album_timestamp = nil
    latest_album_id = nil
    album_list.each do |album|
      if not forbidden_albums.include? album['name']
        if latest_album_timestamp.nil? or latest_album_timestamp.to_time < album['updated_time'].to_time and album['count'] > 8
          latest_album_timestamp = album['updated_time'].to_time
          latest_album_id = album['id']
        end
      end
    end
    new_uri = URI.encode('https://graph.facebook.com/' + latest_album_id + '/photos?' + self.GetAccessToken)
    url = URI.parse(new_uri)
    http = Net::HTTP.new url.host, url.port
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.use_ssl = true
    response = http.request(Net::HTTP::Get.new(url.request_uri))
    jsonHash = JSON.parse(response.body)

    return jsonHash['data']
  end
end