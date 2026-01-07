# Job kiểm tra và chuyển trạng thái hợp đồng sang overdue vào ngày mùng 10 hàng tháng
class PaymentOverdueCheckJob < ApplicationJob
  queue_as :default

  def perform
    current_month = Date.current.month
    current_year = Date.current.year

    # Lấy tất cả hóa đơn chưa thanh toán của tháng hiện tại
    unpaid_invoices = MonthlyInvoice.pending
                                    .for_period(current_month, current_year)
                                    .includes(contract: [:room, :contract_customers])

    unpaid_invoices.find_each do |invoice|
      contract = invoice.contract
      next unless contract.active?

      begin
        # Chuyển trạng thái hóa đơn sang overdue
        invoice.update!(status: :overdue)

        # Chuyển trạng thái hợp đồng sang overdue
        contract.update!(status: :overdue)

        # Gửi email cảnh báo
        ContractMailer.payment_overdue_warning(contract, invoice).deliver_later

        Rails.logger.info "[PaymentOverdueCheckJob] Marked contract #{contract.contract_code} as overdue"
      rescue => e
        Rails.logger.error "[PaymentOverdueCheckJob] Failed to process contract #{contract.contract_code}: #{e.message}"
      end
    end

    Rails.logger.info "[PaymentOverdueCheckJob] Completed. Processed #{unpaid_invoices.count} invoices."
  end
end
