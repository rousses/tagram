require 'twitter'

class TweetStream
  EVENT_KEY = :twitter_user_stream

  attr_reader :bot, :client

  def initialize(bot)
    @bot = bot
    @client = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = Conf[:twitter][:consumer_key]
      config.consumer_secret     = Conf[:twitter][:consumer_secret]
      config.access_token        = Conf[:twitter][:access_token]
      config.access_token_secret = Conf[:twitter][:access_token_secret]
    end
  end

  def run
    bot.loggers.info "[TweetStream] Starting filter"
    client.filter(track: Conf[:tweetstream][:track].join(',')) do |object|
      case object
      when Twitter::Tweet then handle_tweet(object)
      else handle_object(object)
      end
    end
  rescue => e
    bot.loggers.error "[TweetStream] failed!! #{e.inspect} — retry in 120secs."
    sleep 120
    retry
  end

  private
  def handle_tweet(tweet)
    bot.loggers.info "[TweetStream] Tweet: #{tweet.inspect}"
    send_to_channel "[Twitter] #{tweet.user.screen_name}: #{tweet.full_text} — #{tweet.uri}"
  end

  def handle_object(object)
    bot.loggers.info "[TweetStream] Unknown Tweet Object: #{object.inspect}"
  end

  def send_to_channel(text)
    bot.handlers.dispatch(EVENT_KEY, nil, text)
  end

end

module Cinch::Plugins
  class TweetStream
    include Cinch::Plugin

    def initialize(*args)
      super
    end

    listen_to ::TweetStream::EVENT_KEY
    def listen(m, text)
      Channel(Conf[:tweetstream][:channel]).send text
    end

  end
end

