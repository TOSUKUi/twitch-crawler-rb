class Stream < ApplicationRecord
  enum :status,  { ongoing: 1, stopped: 10 }
  has_many :chats

  scope :chats_subscribed, -> { where(chats_subscribed: true) }
end
