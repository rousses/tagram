# -*- coding: utf-8 -*-
#
#Copyright (c) 2013 Brian Haberer
#MIT License
#Permission is hereby granted, free of charge, to any person obtaining
#a copy of this software and associated documentation files (the
#"Software"), to deal in the Software without restriction, including
#without limitation the rights to use, copy, modify, merge, publish,
#distribute, sublicense, and/or sell copies of the Software, and to
#permit persons to whom the Software is furnished to do so, subject to
#the following conditions:
#The above copyright notice and this permission notice shall be
#included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Forked for the needs of Roussetagram

require 'cinch'
require 'cinch/toolbox'
require 'cinch/cooldown'

module Cinch
  module Plugins
    # Plugin to allow users to search wikipedia.
    class Wikipedia
      include Cinch::Plugin

      enforce_cooldown

      self.help = "Utilisez !wiki <terme> pour en retrouver l'article sur Wikipadia"

      match(/wiki(?:pedia)? (.*)/)

      def initialize(*args)
        super
        @max_length = config[:max_length] || 300
      end

      def execute(m, term)
        m.reply wiki(term)
      end

      private

      def wiki(term)
        # URI Encode
        term = URI.escape(term, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        url = "http://fr.wikipedia.org/w/index.php?search=#{term}"

        # Truncate text and url if they are too long
        text = Cinch::Toolbox.truncate(get_def(term, url), @max_length)
        url  = Cinch::Toolbox.shorten(url)

        "Wikipedia ∴ #{text} [#{url}]"
      end

      def get_def(term, url)
        cats = Cinch::Toolbox.get_html_element(url, '#mw-normal-catlinks')
        if cats && cats.include?('homonymie')
          wiki_text = "'#{term} est trop vague et redirige vers une page d'homonymie."
        else
          wiki_text = Cinch::Toolbox.get_html_element(url, '#mw-content-text p')
          if wiki_text.nil? || wiki_text.include?('Spécial:Recherche')
            return not_found(url)
          end
        end
        wiki_text
      end

      def not_found(url)
        msg = "Blargh, j'ai rien pu trouver pour cette recherche, "
        alt_term = Cinch::Toolbox.get_html_element(url, '.searchdidyoumean')
        if alt_term
          alt_term = alt_term[/\AEssayez avec cette orthographe : (\w+)\z/, 1]
          msg << "Tu voulais pas plutôt dire '#{alt_term}'?"
        else
          msg << 'Désolée :/'
        end
        msg
      end
    end
  end
end
