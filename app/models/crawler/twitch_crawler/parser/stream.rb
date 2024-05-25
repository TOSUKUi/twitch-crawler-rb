module Crawler
  module TwitchCrawler
    module Parser
      class Stream
        class << self
          def parse(data)
            data.map do |item|
              {
                id:            item['id'],
                game_id:       item['game_id'].to_i,
                game_name:     item['game_name'],
                is_mature:     item['is_mature'],
                language:      item['language'],
                started_at:    Time.zone.parse(item['started_at']).strftime('%F %T'),
                thumbnail_url: item['thumbnail_url'],
                title:         item['title'],
                data_type:     item['type'],
                user_id:       item['user_id'],
                user_login:    item['user_login'],
                user_name:     item['user_name'],
                status:        :ongoing, # 一応存在するのであればongoing扱いにしたい
                viewer_count:  item['viewer_count'],
                max_viewer:    item['viewer_count'],
                tags:          item['tags']&.join(',')
              }
            end
          end
        end
      end
    end
  end
end
