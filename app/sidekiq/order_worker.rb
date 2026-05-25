class OrderWorker
  include Sidekiq::Worker
  # Chỉ định tác vụ này có độ ưu tiên cao nhất (critical)
  sidekiq_options queue: :critical, retry: 2

  def perform(order_id)
    order = Order.find_by(id: order_id)
    return if order.nil? # Né lỗi nếu đơn hàng vô tình bị xóa trước đó

    # Gọi Service xử lý trừ kho bãi
    service = OrderProcessingService.new(order.sku, order.quantity)

    if service.call
      # Nếu Service trả về true -> Trừ kho thành công -> Hoàn thành đơn hàng
      order.update!(status: "completed")
      Rails.logger.info "🎉 [Sidekiq] Đơn hàng ##{order.id} xử lý THÀNH CÔNG!"
    else
      # Nếu Service trả về false -> Thất bại -> Lưu vết lý do vào DB
      order.update!(
        status: "failed", 
        failure_reason: "Sản phẩm đã hết hàng hoặc không đủ tồn kho!"
      )
      Rails.logger.error "❌ [Sidekiq] Đơn hàng ##{order.id} xử lý THẤT BẠI do hết hàng!"
    end
  end
end