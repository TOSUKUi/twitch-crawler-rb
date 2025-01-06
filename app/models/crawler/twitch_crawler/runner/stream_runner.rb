module Crawler
  module TwitchCrawler
    module Runner
      class StreamRunner < Base
        def run
          cursor = nil
          ts = Time.zone.now.to_i
          f = File.open("#{@before_folder}/#{ts}.json", 'a')
          res = api_client.get_streams(language: 'ja', first: 100).raw
          f.puts(res.body.to_json)
        end


        def parse_file(data_path)
          filename = File.basename(data_path)
          parsed_data = File.readlines(data_path).map do |datum|
            j = JSON.parse(datum)
            Parser::Stream.parse(j['data'])
          end
          insert_data = parsed_data[0]
          current_stream_in_db = Stream.ongoing

          # 1, 2ページ目に配信がなければ配信は停止したとみなすので、そのstream idを抽出する
          current_stream_ids = parsed_data.flatten.pluck(:id).map(&:to_i)
          ended_stream_ids = current_stream_in_db.pluck(:id) - current_stream_ids

          begin
            Stream.import insert_data, on_duplicate_key_update: duplicate_clause
            Stream.where(id: ended_stream_ids).update_all(status: :stopped, ended_at: Time.zone.now)
          rescue StandardError => e
            logger.error(e)
          end

          # 未存在の配信
        end

        def duplicate_clause
          <<~SQL.squish
            `status` = VALUES(`status`),
            tags = VALUES(tags),
            tag_ids = VALUES(tag_ids),
            title = VALUES(title),
            viewer_count = VALUES(viewer_count),
            game_id = VALUES(game_id),
            max_viewer = IF(max_viewer < VALUES(max_viewer), VALUES(max_viewer), max_viewer)
          SQL
        end

        def save_folder_root
          if Rails.env.production?
            '/dev/shm/crawler/twitch/stream'
          else
            'spec/crawled_data/crawler/twitch/stream'
          end
        end
      end
    end
  end
end
