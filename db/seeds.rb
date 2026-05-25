# Xóa sạch dữ liệu cũ nếu có
Order.delete_all
Product.delete_all

# Tạo sản phẩm mẫu iPhone 15 Pro với số lượng tồn kho ban đầu là 50 chiếc
Product.create!(
  name: "iPhone 15 Pro Max 256GB",
  sku: "IPHONE15PRO",
  stock: 50,
  price: 1200.00
)

puts "=== ĐÃ TẠO DỮ LIỆU MẪU: iPhone 15 Pro Max (Tồn kho: 50) ==="