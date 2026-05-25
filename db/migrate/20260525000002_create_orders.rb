class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :order_number, null: false
      t.integer :product_id, null: false
      t.integer :quantity, null: false     
      t.string :status, null: false        
      t.string :customer_email

      t.timestamps
    end
    # Đánh chỉ mục Composite Index phục vụ việc tra cứu lịch sử đơn hàng của khách
    add_index :orders, [:customer_email, :status]
  end
end