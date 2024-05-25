module Crawler
  module TwitchCrawler
    module Parser
      class Chat
        class << self
          def parse(h)
            {
              id:                     h['id'],
              stream_id:              h['stream_id'],
              channel:                h['params'][0].delete('#'),
              error:                  h['error'],
              bits:                   h['bits'],
              ts:                     Time.zone.parse(h['sent_at']),
              text:                   h['params'][1],
              emote_only:             h['additional_info']['emote-only'],
              emotes:                 h['additional_info']['emotes'],
              posinega:               posinega(h['posinega']),
              user_id:                h['user']['id'],
              user_name:              h['user']['name'],
              user_display_name:      h['user']['display_name'],
              user_is_broadcaster:    h['user']['is_broadcaster'],
              user_is_moderator:      h['user']['is_moderator'],
              user_is_subscriber:     h['user']['is_subscriber'],
              user_badge_info:        h['user']['additional_info']['badge-info'],
              user_badges:            h['user']['additional_info']['badges'],
              user_client_nonce:      h['user']['additional_info']['client-nonce'],
              user_color:             h['user']['additional_info']['color'],
              user_first_msg:         h['user']['additional_info']['first-msg'] == '1',
              user_flags:             h['user']['additional_info']['flags'],
              user_mod:               h['user']['additional_info']['mod'] == '1',
              user_returning_chatter: h['user']['additional_info']['returning-chatter'] == '1',
              user_room_id:           h['user']['additional_info']['room-id'],
              user_tmi_sent_ts:       h['user']['additional_info']['tmi-sent-ts'].to_i,
              user_turbo:             h['user']['additional_info']['turbo'] == '1',
              user_type:              h['user']['additional_info']['user-type']
            }
          end
          private
          def posinega(pn)
            top = pn['classes'].max_by { |cls| cls['confidence'] }
            if top['confidence'] > 0.7
              if top['class_name'] == 'positive'
                1
              else
                -1
              end
            else
              0
            end
          end
        end
      end
    end
  end
end
