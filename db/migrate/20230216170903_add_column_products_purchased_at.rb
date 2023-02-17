class AddColumnProductsPurchasedAt < ActiveRecord::Migration[6.0]
  # https://qiita.com/keizokeizo3/items/f2b278a4439bc921b14f
  def change
    add_column :products, :purchased_at, 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP'
  end
end
