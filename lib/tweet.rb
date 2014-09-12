require 'open-uri'
require 'yaml'

module Cinch::Plugins
  class GingerTwitter
    include Cinch::Plugin

    def initialize(*args)
      super
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Conf[:twitter][:consumer_key]
        config.consumer_secret     = Conf[:twitter][:consumer_secret]
        config.access_token        = Conf[:twitter][:access_token]
        config.access_token_secret = Conf[:twitter][:access_token_secret]
      end
    end

    match(/tweet (.+)/, method: :tweet)

    def tweet(m, query)
      # client.update(query)
      if query =~ /(png|jpg|jpeg|gif)/
        img = query.match(/(http[a-zA-Z0-9\:\/\.\-\_]*(jpg|png|jpeg|gif))/)[0]
        txt = query.sub(/(http[a-zA-Z0-9\:\/\.\-\_]*(jpg|png|jpeg|gif))/,"")
        uri = URI.parse(img)
        p media = uri.open
        media.instance_eval("def original_filename; '#{File.basename(uri.path)}'; end")
        tweet = @client.update_with_media(txt, media)
        m.reply "Tweet sent ! #{tweet.uri}"
      else
        tweet = @client.update(query)
        #echo tweet # mais c'est puts hein :>
        m.reply "Tweet sent ! #{tweet.uri}"
      end
    end

  end
end
