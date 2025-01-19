module Crawler
  module TwitchCrawler
    module Parser
      class Video
        def self.parse(data)
          data.map do |datum|
            {
              id:                  datum['stream_id'],
              video_id:            datum['id'],
              video_thumbnail_url: datum['thumbnail_url'],
              video_url:           datum['url'],
              video_view_count:    datum['view_count'],
              video_duration:      parse_duration(datum['duration']),
              video_created_at:    Time.zone.parse(datum['created_at']).strftime('%F %T'),
              video_published_at:  Time.zone.parse(datum['published_at']).strftime('%F %T')
            }
          end
        end

        private

        def self.parse_duration(duration)
          match = /((?<hour>\d+)h)?((?<minute>\d+)m)?((?<second>\d+)s)?/.match(duration)
          hour = match[:hour].to_i * 3600
          minute = match[:minute].to_i * 60
          second = match[:second].to_i
          hour + minute + second
        end
      end
    end
  end
end
