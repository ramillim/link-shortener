class CreateLinksAndLinkVisitsTables < ActiveRecord::Migration[5.2]
  def change
    create_table :links do |t|
      t.string :slug
      t.string :url

      t.timestamps
    end

    add_index :links, :slug, unique: true
    add_index :links, :url, unique: true

    create_table :link_visits do |t|
      t.references :links, foreign_key: true

      t.timestamps
    end

    add_index :link_visits, :created_at
  end
end
