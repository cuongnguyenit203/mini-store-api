# frozen_string_literal: true

class OrderWorker
  include Sidekiq::Worker

  def perform(order_id)
    order = Order.find_by(id: order_id)
    return if order.nil?

    # Lấy sku của sản phẩm thông qua liên kết (Giả sử Order belongs_to :product)
    product_sku = order.product&.sku

    if product_sku.blank?
      order.update!(status: 'failed', failure_reason: 'Không tìm thấy thông tin sản phẩm.')
      return
    end

    # Truyền sku lấy được từ liên kết vào Service Object
    service = OrderProcessingService.new(product_sku, order.quantity)

    if service.call
      order.update!(status: 'completed')
      Rails.logger.info "🎉 [Sidekiq] Đơn hàng ##{order.id} xử lý THÀNH CÔNG!"
    else
      order.update!(
        status: 'failed',
        failure_reason: 'Sản phẩm đã hết hàng hoặc không đủ tồn kho!'
      )
      Rails.logger.error "❌ [Sidekiq] Đơn hàng ##{order.id} xử lý THẤT BẠI do hết hàng!"
    end
  end
end
