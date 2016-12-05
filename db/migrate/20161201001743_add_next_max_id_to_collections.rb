class AddNextMaxIdToCollections < ActiveRecord::Migration[5.0]
  def change
    add_column :collections, :next_max_id, :string
  end
end
