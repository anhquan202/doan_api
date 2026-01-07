class ContractMailer < ApplicationMailer
  # Mail 1: Thông báo tạo hợp đồng thành công
  def contract_created(contract)
    @contract = contract
    @representative = contract.contract_customers.find_by(is_represent: true)&.customer
    @room = contract.room

    return unless @representative&.email.present?

    mail(
      to: @representative.email,
      subject: "[Phòng Trọ] Hợp đồng #{contract.contract_code} đã được tạo thành công"
    )
  end

  # Mail 2: Nhắc nhở thanh toán hàng tháng (gửi mùng 5)
  def payment_reminder(contract, invoice)
    @contract = contract
    @invoice = invoice
    @representative = contract.contract_customers.find_by(is_represent: true)&.customer
    @room = contract.room

    return unless @representative&.email.present?

    mail(
      to: @representative.email,
      subject: "[Phòng Trọ] Nhắc nhở thanh toán tháng #{invoice.month}/#{invoice.year}"
    )
  end

  # Mail 3: Cảnh báo quá hạn thanh toán (gửi mùng 10)
  def payment_overdue_warning(contract, invoice)
    @contract = contract
    @invoice = invoice
    @representative = contract.contract_customers.find_by(is_represent: true)&.customer
    @room = contract.room

    return unless @representative&.email.present?

    mail(
      to: @representative.email,
      subject: "[Phòng Trọ] CẢNH BÁO: Hợp đồng #{contract.contract_code} đã quá hạn thanh toán"
    )
  end
end
