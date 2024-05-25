namespace :crawler do
  namespace :twitch do
    namespace :chat do
      desc 'streamsに基づいてchatを収集'
      task run: :environment do
        Crawler::TwitchCrawler::Runner::ChatRunner.new.run
      end

      task parse: :environment do
        Crawler::TwitchCrawler::Runner::ChatRunner.new.parse
      end
    end

    namespace :stream do
      desc 'streamを収集'
      task run: :environment do
        Crawler::TwitchCrawler::Runner::StreamRunner.new.run
      end

      desc 'streamを格納'
      task parse: :environment do
        Crawler::TwitchCrawler::Runner::StreamRunner.new.parse
      end
    end
  end
end
