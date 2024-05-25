class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats, id: false do |t|
      t.string :id, null: false, primary_key: true, limit: 64
      t.bigint :stream_id, null: false
      t.string :channel, null: false
      t.string :error
      t.integer :bits
      t.datetime :ts, null: false
      t.text :text, null: false
      t.string :emote_only
      t.string :emotes
      t.integer :posinega, limit: 1
      t.string :user_id, null: false, limit: 36
      t.string :user_name, null: false
      t.string :user_display_name, null: false
      t.boolean :user_is_broadcaster, null: false
      t.boolean :user_is_moderator, null: false
      t.boolean :user_is_subscriber, null: false
      t.string :user_badge_info
      t.string :user_badges
      t.string :user_client_nonce
      t.string :user_color
      t.boolean :user_first_msg
      t.string :user_flags
      t.boolean :user_mod
      t.boolean :user_returning_chatter
      t.string :user_room_id, limit: 36
      t.bigint :user_tmi_sent_ts
      t.boolean :user_turbo
      t.string :user_type

      t.timestamps
    end
    add_foreign_key :chats, :streams
  end
end
