class CreateStreams < ActiveRecord::Migration[7.1]
  def change
    create_table :streams, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.integer :game_id, null: false
      t.string :game_name, null: false
      t.boolean :is_mature, null: false
      t.integer :status, null: false, default: 1
      t.string :language, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.text :thumbnail_url, null: false
      t.text :title, null: false
      t.string :data_type, null: false
      t.bigint :user_id, null: false
      t.string :user_login, null: false
      t.string :user_name, null: false
      t.integer :max_viewer, null: false
      t.integer :viewer_count, null: false
      t.string :tag_ids, limit: 1024
      t.string :tags, limit: 1024

      t.timestamps

      t.index :status
    end
  end
end
