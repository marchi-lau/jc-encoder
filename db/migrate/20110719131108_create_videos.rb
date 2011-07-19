class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :filename
      t.integer :duration
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
