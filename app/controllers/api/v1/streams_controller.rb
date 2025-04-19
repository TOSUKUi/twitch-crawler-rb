class Api::V1::StreamsController < ApplicationController
  before_action :set_stream, except: [:index]
  before_action :validate_time_params_present, only: [:index, :time_series]
  before_action :validate_time_order, only: [:index, :time_series]

  # GET /api/v1/streams
  # 直近のアーカイブ一覧 (ページネーション付き)
  def index
    # 配信が終了したものを対象とし、開始時刻の降順で取得
    # .includes() や .select() で必要なデータのみ効率的に取得することを検討
    streams = Stream.stopped.order(max_viewer: :desc).where(started_at: @start_time..@end_time).latest_first
                    .page(params[:page]).per(params[:per_page] || 20) # kaminariでページネーション

    # レスポンスに必要なカラムを選択してJSON化
    render json: {
      streams: streams.map { |stream| stream_summary_for_list(stream) },
      meta:    pagination_meta(streams)
    }
  end

  def details
    # モデルのメソッドを使って詳細情報を取得
    render json: @stream.summary_details
  end

  def time_series
    interval_sec = parse_interval(params[:interval] || 'minute')
    return render json: { error: 'Invalid interval parameter' }, status: :bad_request unless interval_sec

    # Streamモデルの統合メソッド呼び出し
    results = @stream.analyze_volume_and_sentiment(
      start_time:   @start_time,
      end_time:     @end_time,
      interval_sec:
    )
    render json: results
  end


  private

  def set_stream
    @stream = Stream.find_by(id: params[:id])
    render json: { error: 'Stream not found' }, status: :not_found unless @stream
  end

  def validate_time_params_present
    @start_time = parse_time(params[:start_time]) || @stream ? @stream.started_at : 1.day.ago
    @end_time = parse_time(params[:end_time]) || @stream ? @stream.ended_at : Time.zone.now
    unless @start_time && @end_time
      render json:   { error: 'start_time and end_time parameters are required and must be in ISO8601 format' },
             status: :bad_request
    end
  end

  def validate_time_order
    if @start_time && @end_time && @start_time >= @end_time
      render json: { error: 'start_time must be before end_time' }, status: :bad_request
    end
  end

  def parse_time(time_str)
    # ISO 8601形式 (YYYY-MM-DDTHH:MM:SSZ or YYYY-MM-DDTHH:MM:SS+HH:MM) を期待
    Time.iso8601(time_str) rescue nil if time_str.present?
  end

  def parse_interval(interval_str)
    case interval_str.downcase
    when 'minute', '1min' then 60
    when 'hour', '1h' then 3600
    when '10sec', '10s' then 10
    when '30sec', '30s' then 30
    else nil # 不正な値
    end
  end

  # indexアクション用のレスポンスデータ整形
  def stream_summary_for_list(stream)
    {
      id:                  stream.id,
      title:               stream.title,
      user_name:           stream.user_name,
      game_name:           stream.game_name,
      max_viewer:          stream.max_viewer,
      started_at:          stream.started_at&.iso8601,
      ended_at:            stream.ended_at&.iso8601,
      video_id:            stream.video_id,
      video_url:           stream.video_url,
      video_thumbnail_url: stream.video_thumbnail_url,
      video_view_count:    stream.video_view_count,
      video_duration:      stream.video_duration,
    }
  end

  # kaminari のページネーション情報をメタデータとして付与
  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page:    collection.next_page,
      prev_page:    collection.prev_page,
      total_pages:  collection.total_pages,
      total_count:  collection.total_count
    }
  end
end
