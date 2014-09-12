require 'json'
require 'open-uri'
require 'cinch'
require 'curb'

module Cinch::Plugins
  class Wiki
  include Cinch::Plugin
  def initialize(*args)
    super
    @url = Conf[:net:][:wikiurl:]
    @useragent = Conf[:net:][:useragent:]
    end 

    match(/!wiki (.+)/, method: :lookup)
    def lookup(title)
      req = Curl::Easy.new(@url+title) do |curl|
        curl.headers["User-Agent"] = @useragent
        curl.on_body {|d| d1 << d; d.length }
     end 

  end # class Wiki
end # Module Cinch::Plugins

