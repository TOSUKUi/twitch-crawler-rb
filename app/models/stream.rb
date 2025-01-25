class Stream < ApplicationRecord
  enum :status,  { ongoing: 1, stopped: 10 }
  has_many :chats

  scope :chats_subscribed, -> { where(chats_subscribed: true) }


  def generate_analytics(start_date: nil, end_date: nil)
    chats_scope = chats
    chats_scope = chats_scope.where(ts: start_date..end_date) if start_date && end_date

    unique_chatters = chats_scope.distinct.count(:user_id)

    {
      video_id:,
      stream_id:                id,
      engagement_rate:          calculate_engagement_rate(unique_chatters),
      chat_density:             calculate_chat_density(chats_scope),
      chat_timeseries:          calculate_chat_timeseries(chats_scope),
      returning_chatters_ratio: calculate_returning_ratio(chats_scope),
      moderator_activity:       generate_moderator_stats(chats_scope),
      # emote_usage:              generate_emote_stats(chats_scope)
    }
  end

  def generate_metrics(interval:)
    interval_seconds = case interval
                       when 'minute' then 60
                       when 'hour' then 3600
                       when 'day' then 86400
                       end

    {
      stream_id:   id,
      time_series: generate_time_series(interval_seconds)
    }
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

  def calculate_chat_timeseries(chats_scope)
    chats_scope.select('DATE_FORMAT(ts, "%Y-%m-%d %H%i") as ts, COUNT(`posinega` = 0 OR NULL) as neutral, COUNT(`posinega` > 0 OR NULL) as positive, COUNT(`posinega` < 0  OR NULL) as negative').group('ts')
  end

  def calculate_returning_ratio(chats_scope)
    total_chatters = chats_scope.distinct.count(:user_id)
    return 0 if total_chatters.zero?

    returning_chatters = chats_scope.where(user_returning_chatter: true).distinct.count(:user_id)
    (returning_chatters.to_f / total_chatters) * 100
  end

  def generate_moderator_stats(chats_scope)
    mod_chats = chats_scope.where(user_is_moderator: true)
    {
      message_count:   mod_chats.count,
      influence_score: calculate_mod_influence(mod_chats)
    }
  end

  def generate_emote_stats(chats_scope)
    chats_scope.where.not(emotes: nil).map do |chat|
      next if chat.emotes.blank?

      emotes = chat.emotes.split(',')
      emotes.map do |emote|
        {
          emote_id:    emote,
          usage_count: chats_scope.where('emotes LIKE ?', "%#{emote}%").count,
          usage_ratio: calculate_emote_ratio(emote, chats_scope)
        }
      end
    end.compact.flatten.uniq { |e| e[:emote_id] }
  end

  def generate_community_stats(chats_scope)
    total_chatters = chats_scope.distinct.count(:user_id)
    {
      subscriber_ratio:    calculate_subscriber_ratio(chats_scope, total_chatters),
      new_chatter_ratio:   calculate_new_chatter_ratio(chats_scope, total_chatters),
      badge_distribution:  generate_badge_distribution(chats_scope),
      interaction_network: generate_interaction_network(chats_scope)
    }
  end

  def generate_time_series(interval_seconds)
    result = []
    current_time = started_at
    end_time = ended_at || Time.current

    while current_time < end_time
      next_time = current_time + interval_seconds.seconds
      period_chats = chats.where(ts: current_time..next_time)

      result << {
        timestamp:       current_time,
        viewer_count:,
        chat_count:      period_chats.count,
        sentiment_score: calculate_sentiment_score(period_chats)
      }

      current_time = next_time
    end

    result
  end

  def calculate_mod_influence(mod_chats)
    return 0 if chats.count.zero?

    (mod_chats.count.to_f / chats.count) * 100
  end

  def calculate_emote_ratio(emote, chats_scope)
    total_chats = chats_scope.count.to_f
    return 0 if total_chats.zero?

    chats_scope.where('emotes LIKE ?', "%#{emote}%").count / total_chats * 100
  end

  def calculate_subscriber_ratio(chats_scope, total_chatters)
    return 0 if total_chatters.zero?

    subscriber_count = chats_scope.where(user_is_subscriber: true).distinct.count(:user_id)
    (subscriber_count.to_f / total_chatters) * 100
  end

  def calculate_new_chatter_ratio(chats_scope, total_chatters)
    return 0 if total_chatters.zero?

    new_chatters = chats_scope.where(user_first_msg: true).distinct.count(:user_id)
    (new_chatters.to_f / total_chatters) * 100
  end

  def generate_badge_distribution(chats_scope)
    chats_scope.where.not(user_badges: nil).group(:user_badges).count
  end

  def calculate_influencer_score(nodes, edges)
    return 0 if nodes.zero?

    (edges.to_f / nodes) * 100
  end

  def calculate_sentiment_score(period_chats)
    return 0 if period_chats.empty?

    period_chats.average(:posinega).to_f
  end

end
