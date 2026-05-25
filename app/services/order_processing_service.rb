class OrderProcessingService
  def initialize(customer_email, sku, quantity)
    @customer_email = customer_email
    @sku = sku
    @quantity = quantity.to_i
  end

  def call
    # Mở một Database Transaction để đảm bảo tính toàn vẹn dữ liệu (Nếu lỗi sẽ rollback toàn bộ)
    ActiveRecord::Base.transaction do
      
      # GIẢI PHÁP SENIOR: Sử dụng .lock("FOR UPDATE") để khóa dòng sản phẩm này lại.
      # Nếu có request khác cùng sửa sản phẩm này, nó bắt buộc phải xếp hàng đợi request này chạy xong.
      product = Product.lock("FOR UPDATE").find_by(sku: @sku)

      if product.nil?
        Rails.logger.error "Không tìm thấy sản phẩm với mã SKU: #{@sku}"
        return false
      end

      # Kiểm tra xem kho còn đủ hàng để bán không
      if product.stock < @quantity
        Rails.logger.warn "Sản phẩm #{product.name} đã hết hàng hoặc không đủ tồn kho!"
        return false
      end

      # 1. Trừ số lượng tồn kho của sản phẩm
      product.update!(stock: product.stock - @quantity)

      # 2. Tạo đơn hàng với trạng thái thành công (completed)
      Order.create!(
        order_number: "STORE-#{Time.current.to_i}-#{SecureRandom.hex(4).upcase}",
        product_id: product.id,
        quantity: @quantity,
        status: "completed",
        customer_email: @customer_email
      )
    end
    true
  rescue => e
    Rails.logger.error "Lỗi hệ thống khi xử lý đơn hàng: #{e.message}"
    false
  end
end