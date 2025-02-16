class CreateBlobs < ActiveRecord::Migration[8.0]
  def change
    create_table :blobs do |t|
      t.string :uid
      t.integer :size
      t.datetime :created_at
      t.string :storage_backend
      t.string :storage_identifier
    end
    add_index :blobs, :uid, unique: true
  end
end
