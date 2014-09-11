require "cinch"
	
module Cinch::Plugins
    class EasterEggs
    	include Cinch::Plugin
		def initialize(*args)
			super
        end
       
      match(/cheveux/, method: :cheveux)
        def cheveux(m)
			m.action_reply 'secoue ses cheveux'
		end
	
end

end
