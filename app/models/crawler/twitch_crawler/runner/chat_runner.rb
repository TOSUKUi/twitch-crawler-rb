module Crawler
  module TwitchCrawler
    module Runner
      class ChatRunner < Base
        def run
          channels = Stream.ongoing.pluck(:user_login).map { |c| "##{c}" }.join(',')
          channle_stream_id_hash = Stream.ongoing.pluck(:user_login, :id).to_h { |c, id| [c, id] }

          client = TwitchIRCClient.new('irc.chat.twitch.tv', '6667', {
                                         nick:    'tosukuibot',
                                         pass:    "oauth:#{api_client(token_type: :user,
                                                                      scopes:     'chat:read chat:edit').tokens.access_token}",
                                         channel: '#tosukui'
                                       })
          client.start_twitch(@before_folder, channle_stream_id_hash)
        end

        def parse_file(doing_path)
          chats = File.open(doing_path, 'r').readlines.map { |chat| JSON.parse(chat) }
          posinegaes = Api::Asari.ping_array(chats)
          data = chats.zip(posinegaes).map do |chat, posinega|
            chat['posinega'] = posinega
            Parser::Chat.parse(chat)
          end
          Chat.import data, on_duplicate_key_ignore: true
        end

        def save_folder_root
          if Rails.env.production?
            '/dev/shm/crawler/twitch/chat'
          else
            'spec/crawled_data/crawler/twitch/chat'
          end
        end

        class TwitchIRCClient < Net::IRC::Client
          def start_twitch(save_folder, channle_stream_id_hash)
            @channle_stream_id_hash = channle_stream_id_hash
            @save_folder = save_folder
            @buffer = []
            # reset config
            @server_config = Message::ServerConfig.new
            @socket = TCPSocket.open(@host, @port)
            on_connected
            post 'CAP REQ', ':twitch.tv/membership twitch.tv/tags twitch.tv/commands'
            post PASS, @opts.pass if @opts.pass
            post NICK, @opts.nick
            post 'JOIN', @opts.channel if @opts.channel
            while l = @socket.gets
              begin
                m = twitch_message_parse(l)

                puts l
                next if m.nil?
                next if on_message(m) === true

                name = "on_#{(COMMANDS[m.command.upcase] || m.command).downcase}"
                send(name, m) if respond_to?(name)
              rescue Exception => e
                warn e
                warn e.backtrace.join("\r\t")
                raise
              rescue Message::InvalidMessage
                @log.error 'MessageParse: ' + l.inspect
              rescue StandardError => e
              end
            end
          rescue IOError
          ensure
            File.write("#{@save_folder}/twitch_#{Time.zone.now.to_i}.json", @buffer.join)
            finish
          end

          def twitch_message_parse(l)
            Ext::Twitch::Chat::Message.new(l)
          end

          def on_pong(m)

          end

          def on_privmsg(m)
            @buffer ||= []
            mj = m.as_json
            mj['stream_id'] = @channle_stream_id_hash[mj['channel']]
            @buffer << "#{mj.to_json}\n"
            return unless @buffer.length > 100

            File.write("#{@save_folder}/twitch_#{Time.zone.now.to_i}.json", @buffer.join)
            @buffer = []
          end

          def on_rpl_welcome(m); end
        end
      end
    end
  end
end
