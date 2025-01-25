# app/controllers/api/v1/streams_controller.rb
module Api
  module V1
    class StreamsController < BaseController

      def index
        render json: Stream.not_ongoing.where('max_viewer > ?', 2000).order(started_at:       :desc,
                                                                            video_view_count: :desc).limit(100)
      end

      def show
        stream = Stream.find(params[:id])
        render json: stream
      end

      def analytics
        stream = Stream.find(params[:id])
        analytics_data = stream.generate_analytics(
          start_date: params[:start_date],
          end_date:   params[:end_date]
        )

        render json: analytics_data
      end

      def metrics
        stream = Stream.find(params[:id])
        metrics_data = stream.generate_metrics(
          interval: params[:interval] || 'hour'
        )

        render json: metrics_data
      end
    end
  end
end
