class Dropbox
  def self.GetAuth
    require 'dropbox_sdk'

# Get your app key and secret from the Dropbox developer website
    APP_KEY = 'hp1ts9qfa1bt0p3'
    APP_SECRET = 'z0oheqs4dwalkgq'

    flow = DropboxOAuth2FlowNoRedirect.new(APP_KEY, APP_SECRET)
  end
end