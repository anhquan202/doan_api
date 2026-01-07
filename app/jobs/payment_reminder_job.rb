# Job gửi email nhắc nhở thanh toán vào ngày mùng 5 hàng tháng
class PaymentReminderJob < ApplicationJob
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
        ContractMailer.payment_reminder(contract, invoice).deliver_later
        Rails.logger.info "[PaymentReminderJob] Sent reminder for contract #{contract.contract_code}"
      rescue => e
        Rails.logger.error "[PaymentReminderJob] Failed to send reminder for contract #{contract.contract_code}: #{e.message}"
      end
    end

    Rails.logger.info "[PaymentReminderJob] Completed. Processed #{unpaid_invoices.count} invoices."
  end
end
