class Stream < ApplicationRecord
  enum :status,  { ongoing: 1, stopped: 10 }
  has_many :chats

  scope :chats_subscribed, -> { where(chats_subscribed: true) }

  def channel_subscribed_collectly?
    return true if !chats_subscribed? || chats_subscribed_at > 10.minutes.ago

    redis_client.exists?("stream_alive_flag_#{id}")
  end

  private

  def redis_client
    Redis.new(host: 'localhost', port: 6379)
  end


end
