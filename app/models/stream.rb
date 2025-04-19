class Stream < ApplicationRecord
  enum :status,  { ongoing: 1, stopped: 10 }
  has_many :chats

  scope :chats_subscribed, -> { where(chats_subscribed: true) }
  # 新しい順 (開始時刻でソート)
  scope :latest_first, -> { order(started_at: :desc) }

  # 配信時間を計算 (秒)
  def duration_seconds
    return nil unless started_at && ended_at

    (ended_at - started_at).to_i
  end

  def summary_details
    details = {
      id:,
      title:,
      user_id:,
      user_login:,
      user_name:,
      game_id:,
      game_name:,
      language:,
      started_at:       started_at&.iso8601,
      ended_at:         ended_at&.iso8601,
      duration_seconds:, # 計算した配信時間
      max_viewer:,
      # video_* カラムは video が存在すれば追加
    }
    if video_id.present?
      details.merge!({
                       video_id:,
                       video_url:,
                       video_thumbnail_url:,
                       video_view_count:,
                       video_duration:, # Twitch提供の動画時間
                       video_created_at:    video_created_at&.iso8601,
                       video_published_at:  video_published_at&.iso8601,
                     })
    end
  end

  def analyze_volume_and_sentiment(start_time:, end_time:, interval_sec:)
    # interval_sec を使ってタイムスタンプをグルーピングするキーを生成
    # FLOOR(UNIX_TIMESTAMP(ts) / interval_sec) は、指定した秒数間隔で時刻を丸める
    time_group_sql = "FLOOR(UNIX_TIMESTAMP(ts) / #{interval_sec.to_i})"

    select_sql = <<~SQL.squish
      #{time_group_sql} AS time_group,
      COUNT(*) AS total_count,
      SUM(CASE WHEN posinega = 1 THEN 1 ELSE 0 END) AS positive_count,
      SUM(CASE WHEN posinega = -1 THEN 1 ELSE 0 END) AS negative_count,
      SUM(CASE WHEN posinega = 0 THEN 1 ELSE 0 END) AS neutral_count
    SQL
    # index(stream_id, ts) を利用して絞り込み、集計
    results = chats
              .where(ts: start_time..end_time)
              .select(select_sql)
              .group('time_group')
              .order('time_group ASC')

    # 結果を整形
    # results は ActiveRecord_Relation オブジェクトで、各要素が time_group, total_count などを持つ
    results.map do |result|
      # time_group は UNIXタイムスタンプを interval_sec で割って floor した値なので、
      # interval_sec を掛けて元の時間範囲の開始時刻に戻す
      timestamp = result.time_group * interval_sec
      {
        time:     Time.at(timestamp).iso8601,
        count:    result.total_count, # チャット総数
        positive: result.positive_count || 0, # 結果がなければ 0 に
        negative: result.negative_count || 0,
        neutral:  result.neutral_count || 0
      }
    end
  end

  private

  def calculate_engagement_rate(unique_chatters)
    return 0 if viewer_count.zero?

    (unique_chatters.to_f / viewer_count) * 100
  end

  def calculate_chat_density(chats_scope)
    duration = ((ended_at || Time.current) - started_at) / 60
    return 0 if duration.zero?

    chats_scope.count.to_f / duration
  end



end
