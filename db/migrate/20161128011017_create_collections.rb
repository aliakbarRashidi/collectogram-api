class CreateCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :collections do |t|
      t.string :name
      t.string :tag
      t.date :start_date
      t.date :end_date
      t.string :next_id
      t.string :unique_url
      t.boolean :is_public
      t.boolean :is_empty

      t.timestamps
    end
  end
end
