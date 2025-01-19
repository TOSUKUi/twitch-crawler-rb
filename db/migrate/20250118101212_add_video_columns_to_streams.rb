class AddVideoColumnsToStreams < ActiveRecord::Migration[7.1]
  def change
    change_table :streams, bulk: true do |t|
      t.string :video_id
      t.string :video_thumbnail_url
      t.string :video_url
      t.integer :video_view_count
      t.integer :video_duration
      t.datetime :video_created_at
      t.datetime :video_published_at
    end
  end
end
