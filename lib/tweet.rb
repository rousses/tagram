require 'uri'
require 'open-uri'
require 'yaml'

module Cinch::Plugins
  class GingerTwitter
    include Cinch::Plugin

    match(/tweet (.+)/, method: :tweet)
    match(/fav (.+)/, method: :favorite)
    match(/rt (.+)/, method: :retweet)
    match(/untweet (.+)/, method: :remove_tweet)

    def tweet(m, query)
      text, media = extract_text_and_media(query)
      is_nsfw = !text.match(/nsfw/i).to_a.empty?
      options = {possibly_sensitive: is_nsfw}
      post_tweet(text, media)
    rescue => err
      m.reply "FAIL! #{err.class.to_s}: #{err.message}"
    end

    # !rt 516525315368423424
    # !rt https://twitter.com/DashieV3/status/516525315368423424
    def retweet(m, id_or_url)
      id = extract_tweet_id_from_url(id_or_url)
      twitter.retweet!(id)
    rescue => err
      m.reply "FAIL! #{err.class.to_s}: #{err.message}"
    end

    # !fav 516525315368423424
    # !fav https://twitter.com/DashieV3/status/516525315368423424
    def favorite(m, id_or_url)
      id = extract_tweet_id_from_url(id_or_url)
      twitter.favorite!(id)
    rescue => err
      m.reply "FAIL! #{err.class.to_s}: #{err.message}"
    end

    # !untweet 514807817480712193
    # !untweet https://twitter.com/roussestagram/status/514807817480712193
    def remove_tweet(m, id_or_url)
      id = extract_tweet_id_from_url(id_or_url)
      twitter.destroy_status(id)
    rescue => err
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

    def extract_text_and_media(query)
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

    def extract_tweet_id_from_url(url)
      if url =~ /\A\d+\z/ # in case we only got an id
        url
      else
        uri = URI.parse(url)
        _, nick, status, id = uri.path.split('/')
        status == "status" ? id : nil
      end
    end

  end
end
