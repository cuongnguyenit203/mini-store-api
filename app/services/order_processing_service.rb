class OrderProcessingService
  def initialize(sku, quantity)
    @sku = sku
    @quantity = quantity.to_i
  end

  def call
    # Hứng kết quả của cả khối transaction vào một biến
    result = ActiveRecord::Base.transaction do
      product = Product.lock('FOR UPDATE').find_by(sku: @sku)

      if product.nil?
        Rails.logger.error "🚨 [Service] Không tìm thấy SKU: #{@sku}"
        raise ActiveRecord::Rollback # Trả về nil cho biến result
      end

      if product.stock < @quantity
        Rails.logger.warn "🚨 [Service] Không đủ tồn kho cho sản phẩm #{product.name}!"
        raise ActiveRecord::Rollback # Trả về nil cho biến result
      end

      # Trừ kho nếu đủ hàng
      product.update!(stock: product.stock - @quantity)

      true # 👈 Nếu chạy đến đây ngon lành, biến result sẽ ăn giá trị TRUE
    end

    # Cuối cùng, mình kiểm tra biến result xem là true hay nil
    # Nếu result có giá trị (true) -> hàm call trả về true. Nếu result bị nil -> trả về false!
    result ? true : false
  rescue StandardError => e
    Rails.logger.error "❌ [Service Error] Lỗi hệ thống: #{e.message}"
    false
  end
end
