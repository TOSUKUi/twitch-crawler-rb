module Crawler
  module TwitchCrawler
    module Runner
      class VideoRunner < Base
        def run
          # https://clips.twitch.tv/create?broadcastID=314209504760&broadcasterLogin=sasatikk&offsetSeconds=15805&vodID=2355449370
          cursor = nil
          ts = Time.zone.now.to_i
          streams = Stream.where(video_id: nil).where('updated_at > ?', 1.day.ago).select(:user_id).distinct
          streams.each do |stream|
            res = api_client.get_videos(user_id: stream.user_id, first: 10).raw
            f = File.open("#{@before_folder}/#{stream.user_id}_#{ts}.json", 'a')
            f.puts(res.body.to_json)
            sleep(1)
          end
        end


        def parse_file(data_path)
          filename = File.basename(data_path)
          f = File.read(data_path)
          return unless f.present?

          j = JSON.parse(f)
          parsed_data = Parser::Video.parse(j['data'])
          existing_streams = Stream.where(id: parsed_data.pluck(:id)).select(:id)
          insert_streams = existing_streams.filter_map do |stream|
            video_data = parsed_data.find { |d| d[:id].to_i == stream.id }
            if video_data.present?
              stream.assign_attributes(video_data)
              stream.save
            else
              nil
            end
          end
        end

        def save_folder_root
          if Rails.env.production?
            '/dev/shm/crawler/twitch/video'
          else
            'spec/crawled_data/crawler/twitch/video'
          end
        end
      end
    end
  end
end
