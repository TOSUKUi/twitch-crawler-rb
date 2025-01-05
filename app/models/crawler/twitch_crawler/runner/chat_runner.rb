module Crawler
  module TwitchCrawler
    module Runner
      class ChatRunner < Base
        def run
          channel_last_chat_times = {}
          channel_crawling_threads = {}
          Stream.ongoing.update_all(chats_subscribed_at: nil, chats_subscribed: false)
          loop do
            ongoing_channels = Stream.ongoing
                                     .group_by(&:user_id)
                                     .transform_values { |streams| streams.max_by(&:started_at) }
                                     .values

            subscribed_channels = ongoing_channels.select { |stream| stream.chats_subscribed? }
            ended_channels = Stream.chats_subscribed.not_ongoing

            # 終了チャンネルを見ているスレッドを停止
            ended_channels.each do |stream|
              channel_crawling_threads.delete(stream.id)&.exit
              stream.update(chats_subscribed: false)
            end

            # すでにスレッドに登録されているのに、チャットの情報が受け取れていないチャンネルを終了する
            subscribed_channels.each do |stream|
              if channel_last_chat_times[stream.id] <= 10.minutes.ago
                channel_crawling_threads.delete(stream.id)&.exit
                stream.update(chats_subscribed: false)
              end
            end

            subscribe_channels = Stream.ongoing.where(chats_subscribed: false)

            # 未収集チャンネルにJOIN
            bot_name = ENV.fetch('TWITCH_BOT_NAME').dup
            subscribe_channels.each do |stream|
              th = Thread.new do
                client = TwitchIRCClient.new('irc.chat.twitch.tv', '6667', {
                                               nick:    bot_name,
                                               pass:    "oauth:#{api_client(token_type: :user,
                                                                            scopes:     'chat:edit chat:read').tokens.access_token}",
                                               channel: "##{stream.user_login}"
                                             })
                client.start_twitch(@before_folder, stream, channel_last_chat_times)
              end
              stream.update(chats_subscribed_at: Time.zone.now, chats_subscribed: true)
              channel_crawling_threads[stream.id] = th

              # 0.7秒のsleepをかます -> 20 authentication attempts per 10 seconds per user. from: https://dev.twitch.tv/docs/irc/#rate-limits
              sleep(0.7)
            end

            begin
              redis_client.set(:running_channel, channel_crawling_threads.keys)
            rescue StandardError => e
            end

            # とりまloopは10秒ごとに行う
            sleep(10)
          end
        ensure
          channel_crawling_threads.values.map(&:exit)
          Stream.where(id: channel_crawling_threads.keys).update_all(chats_subscribed: false)
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



        private


        def redis_client
          @redis_client ||= Redis.new(host: 'localhost', port: 6379)
        end

        class TwitchIRCClient < Net::IRC::Client
          def start_twitch(save_folder, stream, channel_last_chat_times)
            @channel_last_chat_times = channel_last_chat_times
            @stream = stream
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
            @channel_last_chat_times[stream.id] = Time.zone.now
            while l = @socket.gets
              begin
                m = twitch_message_parse(l)

                next if m.nil?
                next if on_message(m) === true

                name = "on_#{(COMMANDS[m.command.upcase] || m.command).downcase}"
                send(name, m) if respond_to?(name)
              rescue Message::InvalidMessage
                @log.error 'MessageParse: ' + l.inspect
              rescue StandardError => e
              end
            end
          rescue IOError
          ensure
            File.write("#{@save_folder}/twitch_#{Time.zone.now.to_i}_#{@opts.channel}.json", @buffer.join)
            finish
          end

          def twitch_message_parse(l)
            Ext::Twitch::Chat::Message.new(l)
          end

          def on_pong(m)
          end

          def join_channel
            super
          end

          def part_channel
          end

          def on_privmsg(m)
            @buffer ||= []
            mj = m.as_json
            mj['stream_id'] = @stream.id
            @buffer << "#{Oj.dump(mj, mode: :compat)}\n"
            @channel_last_chat_times[@stream.id] = Time.zone.now
            return unless @buffer.length > 100

            File.write("#{@save_folder}/twitch_#{Time.zone.now.to_i}_#{@opts.channel}.json", @buffer.join)
            @buffer = []
          end

          def on_rpl_welcome(m); end
        end
      end
    end
  end
end
