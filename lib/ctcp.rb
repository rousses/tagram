require "time"


module Cinch::Plugins
    class BasicCTCP
      include Cinch::Plugin

      ctcp :version
      ctcp :time
      ctcp :ping
      ctcp :source
      ctcp :clientinfo
      def ctcp_version(m)
        m.ctcp_reply Conf[:irc][:version] if reply_to_ctcp?(:version)
      end

      def ctcp_time(m)
        m.ctcp_reply Time.now.strftime("%a %b %d %H:%M:%S %Z %Y") if reply_to_ctcp?(:time)
      end

      def ctcp_ping(m)
        m.ctcp_reply m.ctcp_args.join(" ") if reply_to_ctcp?(:ping)
      end

      def ctcp_source(m)
        m.ctcp_reply "https://github.com/rousses/tagram" if reply_to_ctcp?(:source)
      end

      def ctcp_clientinfo(m)
        m.ctcp_reply "ACTION PING VERSION TIME CLIENTINFO SOURCE" if reply_to_ctcp?(:clientinfo)
      end

      def reply_to_ctcp?(command)
        commands = config[:commands]
        commands.nil? || commands.include?(command)
      end
    end
  end
end

