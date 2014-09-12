require 'open-uri'
require 'yaml'

module Cinch::Plugins
  class GingerTwitter
    include Cinch::Plugin

    match(/tweet (.+)/, method: :tweet)

    def tweet(m, query)
      text, media = extract_text_and_media(query)
      is_nsfw = !text.match(/nsfw/i).to_a.empty?
      options = {possibly_sensitive: is_nsfw}
      post_tweet(text, media)
    rescue err
      m.reply "FAIL! #{err.class.to_s}: #{err.message}"
    end

    private
    def twitter
      @twitter ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = Conf[:twitter][:consumer_key]
        config.consumer_secret     = Conf[:twitter][:consumer_secret]
        config.access_token        = Conf[:twitter][:access_token]
        config.access_token_secret = Conf[:twitter][:access_token_secret]
      end
    end

    def post_tweet(text, media=nil, options = {})
      media ? twitter.update_with_media!(text, media, options) : twitter.update!(text, options)
    end

    def extract_text_and_media(text)
      if query =~ /(png|jpg|jpeg|gif)/
        img = query.match(/(http[a-zA-Z0-9\:\/\.\-\_]*(jpg|png|jpeg|gif))/)[0]
        text = query.sub(/(http[a-zA-Z0-9\:\/\.\-\_]*(jpg|png|jpeg|gif))/,"")
        uri = URI.parse(img)
        media = uri.open
        media.instance_eval("def original_filename; '#{File.basename(uri.path)}'; end")
        [text, media]
      else
        [query, nil]
      end
    end

  end
end
