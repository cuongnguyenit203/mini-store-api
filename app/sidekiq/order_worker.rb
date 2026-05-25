class OrderWorker
  include Sidekiq::Worker
  # Chỉ định tác vụ này có độ ưu tiên cao nhất (critical)
  sidekiq_options queue: :critical, retry: 2

  def perform(customer_email, sku, quantity)
    # Triển khai gọi Service Object xử lý ngầm ở background
    OrderProcessingService.new(customer_email, sku, quantity).call
    
  end
end