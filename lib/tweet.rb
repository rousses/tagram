require 'uri'
require 'open-uri'
require 'yaml'

module Cinch::Plugins
  class GingerTwitter
    include Cinch::Plugin

    class IRCError < RuntimeError; end

    match(/tweet (.+)/, method: :tweet)
    match(/fav (.+)/, method: :favorite)
    match(/rt (.+)/, method: :retweet)
    match(/untweet (.+)/, method: :remove_tweet)

    def tweet(m, query)
      wrap m, query, -> (m, query) {
        text, media = extract_text_and_media(query)
        is_nsfw = !text.match(/nsfw/i).to_a.empty?
        options = {possibly_sensitive: is_nsfw}
        post_tweet(text, media)
      }
    end

    # !rt 516525315368423424
    # !rt https://twitter.com/DashieV3/status/516525315368423424
    def retweet(m, id_or_url)
      wrap m, id_or_url, -> (m, id_or_url) {
        id = extract_tweet_id_from_url(id_or_url)
        twitter.retweet!(id)
        m.reply "Retweeted!"
      }
    end

    # !fav 516525315368423424
    # !fav https://twitter.com/DashieV3/status/516525315368423424
    def favorite(m, id_or_url)
      wrap m, id_or_url, -> (m, id_or_url) {
        id = extract_tweet_id_from_url(id_or_url)
        twitter.favorite!(id)
        m.reply "♥"
      }
    end

    # !untweet 514807817480712193
    # !untweet https://twitter.com/roussestagram/status/514807817480712193
    def remove_tweet(m, id_or_url)
      wrap m, id_or_url, -> (m, id_or_url) {
        id = extract_tweet_id_from_url(id_or_url)
        twitter.destroy_status(id)
        m.reply "Tweet killed."
      }
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

    # Wrap blck with basic behaviour (just rescues, actually)
    def wrap(m, query, blck)
      blck.call(m, query)
    rescue IRCError => err
      m.reply "You fail! #{err.message}"
    rescue Twitter::Error => err
      m.reply "Twitter error: #{err.message}"
    rescue => err
      m.reply "/me slaps Asone #{err.class.to_s}: #{err.message}"
    end

    def post_tweet(text, media=nil, options = {})
      media ? twitter.update_with_media!(text, media, options) : twitter.update!(text, options)
    end

    def extract_text_and_media(query)
      medias = query.scan(/(http[a-zA-Z0-9\:\/\.\-\_]*(jpg|png|jpeg|gif))/)
      return [query, nil] if medias.empty?
      raise(IRCError, "Tweets can only contain one media!") if medias.size > 1
      media = medias.first.first
      text = query.gsub(media, "")
      media_uri = URI.parse(media)
      media_file = media_uri.open
      media_file.instance_eval("def original_filename; '#{File.basename(media_uri.path)}'; end")
      [text, media_file]
    end

    def extract_tweet_id_from_url(url)
      if url =~ /\A\d+\z/ # in case we only got an id
        url
      else
        uri = URI.parse(url)
        _, nick, status, id = uri.path.split('/')
        status == "status" ? id : raise(IRCError, "'#{url}' is neither an ID nor a tweet url")
      end
    end

  end
end
