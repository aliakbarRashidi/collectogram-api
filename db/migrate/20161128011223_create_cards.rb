class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.references :collection, foreign_key: true
      t.text :content_caption
      t.string :content_url
      t.string :content_link
      t.string :user_handle
      t.string :user_icon
      t.boolean :is_video
      t.datetime :tag_time

      t.timestamps
    end
  end
end
