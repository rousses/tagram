#!/usr/bin/env ruby
# encoding: utf-8

lib = File.join(File.expand_path('..', __FILE__), '/lib')
$:.unshift lib unless $:.include?(lib)
require 'bundler'
Bundler.require

require 'yaml'

%w(ctcp wikipedia tweet tweet_stream jeveux eastereggs).each {|r|
  require r
}

Conf = YAML.load_file("config.yml")

bot = Cinch::Bot.new do
  configure do |c|
    c.server = Conf[:irc][:server]
    c.nick = Conf[:irc][:nick]
    c.user = Conf[:irc][:user]
    c.realname = Conf[:irc][:realname]
    c.channels = Conf[:irc][:channels]
    c.plugins.plugins = [Cinch::Plugins::GingerTwitter, Cinch::Plugins::Identify,
                         Cinch::Plugins::Jeveux, Cinch::Plugins::EasterEggs,
                         Cinch::Plugins::TweetStream, Cinch::Plugins::Wikipedia, Cinch::Plugins::UrlScraper, Cinch::Plugins::BasicCTCP]
    c.plugins.options[Cinch::Plugins::Identify] = Conf[:irc][:irc_auth]
  end
end

Thread.new { ::TweetStream.new(bot).run }

bot.start
