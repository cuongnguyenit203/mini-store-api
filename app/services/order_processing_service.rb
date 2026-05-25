class OrderProcessingService
  def initialize(sku, quantity)
    @sku = sku
    @quantity = quantity.to_i
  end

  def call
    # Mở Transaction để đảm bảo tính toàn vẹn, nếu có lỗi bất kỳ sẽ rollback kho về như cũ
    ActiveRecord::Base.transaction do
      # Khóa dòng sản phẩm để chống tranh chấp (Race Condition)
      product = Product.lock("FOR UPDATE").find_by(sku: @sku)

      if product.nil?
        Rails.logger.error "🚨 [Service] Không tìm thấy sản phẩm với mã SKU: #{@sku}"
        raise ActiveRecord::Rollback # Hủy transaction
      end

      # Kiểm tra tồn kho
      if product.stock < @quantity
        Rails.logger.warn "🚨 [Service] Sản phẩm #{product.name} không đủ tồn kho! (Cần: #{@quantity}, Còn: #{product.stock})"
        raise ActiveRecord::Rollback # Hủy transaction nếu thiếu hàng
      end

      # Trừ số lượng tồn kho của sản phẩm
      product.update!(stock: product.stock - @quantity)
    end
    true # Trả về true nếu trừ kho thành công ngon lành
  rescue => e
    Rails.logger.error "❌ [Service Error] Lỗi khi trừ kho: #{e.message}"
    false # Trả về false nếu có bất kỳ lỗi nào xảy ra hoặc bị Rollback
  end
end