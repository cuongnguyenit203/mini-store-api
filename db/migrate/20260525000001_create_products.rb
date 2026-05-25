# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.integer :stock, null: false, default: 0
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps
    end
    # Đánh chỉ mục Index để tìm kiếm sản phẩm siêu nhanh bằng mã SKU
    add_index :products, :sku, unique: true
  end
end
