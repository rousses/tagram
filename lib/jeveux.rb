# encoding: utf-8
require "cinch"

module Cinch::Plugins
    class Jeveux
    	include Cinch::Plugin
		def initialize(*args)
			super
        end
        
		match(/jeveux$/, method: :randomjeveux)
		
		def randomjeveux(m)
			jeveux = YAML.load_file('jeveux.yaml') 
			r = Random.new.rand(0..(jeveux['jeveux'].length.to_i-1)) 
			jv = 'Jeveux '+jeveux['jeveux'][r.to_i]+' - #'+r.to_s+'/'+jeveux['jeveux'].length.to_s
			m.reply(jv)
		end
		
		match(/jeveux (([a-zA-Z0-9]+)(.*))/, method: :jeveux)
		def jeveux(m,query,param,opt)
		
		filename = 'jeveux.json'

		if File.file?(filename) === false
			File.open("jeveux.json", "w+") { |file| file.write("") }
		end
		jeveux = YAML.load_file('jeveux.yaml') 

		case param
			when 'remove'
				if ((opt =~ /[0-9]{1,3}$/) && (opt.to_i < jeveux['jeveux'].length-1))
					jeveux['jeveux'].slice(opt.to_i,1)
					File.open('jeveux.yaml', 'w') {|f| f.write jeveux.to_yaml } 
					m.reply 'jeveux supprimé'
				else
					m.reply 'ce jeveux est introuvable'
				end
			when 'list'
				m.reply 'commande indisponible'
			else
				
				if query =~ /^[0-9]{1,3}/
					nbr = query.match(/^[0-9]{1,3}/)[0]
    					if(nbr.to_i > jeveux['jeveux'].length)
						m.reply('ce !jeveux n\'existe pas')
					else
						jeveuxSingle = jeveux['jeveux'][nbr.to_i-1]
						m.reply(' jeveux #' + nbr.to_i.to_s +  '/' + jeveux['jeveux'].length.to_s + ' : je veux ' + jeveuxSingle.to_s)
					end
				else
					jeveux['jeveux'].push(query)
					m.reply('je veux enregistré - ' + jeveux['jeveux'].length.to_s + ' jeveux dans la liste ')
					File.open('jeveux.yaml', 'w') {|f| f.write jeveux.to_yaml } 	
				end
		end
					
		end
		
end

end
