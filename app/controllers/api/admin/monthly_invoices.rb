module Api
  module Admin
    class MonthlyInvoices < Grape::API
      resource :monthly_invoices do
        # ============================================
        # List invoices by period
        # ============================================
        desc "List invoices by period"
        params do
          optional :month, type: Integer, desc: "Month (1-12)"
          optional :year, type: Integer, desc: "Year"
          optional :status, type: String, values: MonthlyInvoice.statuses.keys, desc: "Filter by status"
          optional :contract_id, type: Integer, desc: "Filter by contract"
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
        end
        get do
          invoices = MonthlyInvoice.includes(contract: :room)

          invoices = invoices.for_period(params[:month], params[:year]) if params[:month] && params[:year]
          invoices = invoices.where(status: params[:status]) if params[:status].present?
          invoices = invoices.where(contract_id: params[:contract_id]) if params[:contract_id].present?

          invoices = invoices.order(year: :desc, month: :desc).paginate(page: params[:page], per_page: params[:per_page])

          ok_response data: {
            invoices: ActiveModelSerializers::SerializableResource.new(
              invoices,
              each_serializer: MonthlyInvoiceSerializer
            ),
            meta: paginate_meta(invoices)
          }
        end

        # ============================================
        # Get invoice detail
        # ============================================
        desc "Get invoice detail"
        params do
          requires :id, type: Integer, desc: "Invoice ID"
        end
        get ":id" do
          invoice = MonthlyInvoice.includes(contract: :room).find(params[:id])

          ok_response data: {
            invoice: MonthlyInvoiceDetailSerializer.new(invoice)
          }
        end

        # ============================================
        # Generate invoices for a period (bulk)
        # ============================================
        desc "Generate invoices for all active contracts in a period"
        params do
          requires :month, type: Integer, desc: "Month (1-12)"
          requires :year, type: Integer, desc: "Year"
        end
        post :generate do
          result = ::Admin::GenerateBulkMonthlyInvoicesService.new(
            month: params[:month],
            year: params[:year]
          ).call

          ok_response(
            data: {
              generated_count: result[:success].count,
              error_count: result[:errors].count,
              invoices: result[:success],
              errors: result[:errors]
            },
            message: "Đã tạo #{result[:success].count} hóa đơn"
          )
        end

        # ============================================
        # Generate single invoice for a contract
        # ============================================
        desc "Generate invoice for a specific contract"
        params do
          requires :contract_id, type: Integer, desc: "Contract ID"
          requires :month, type: Integer, desc: "Month (1-12)"
          requires :year, type: Integer, desc: "Year"
        end
        post :generate_single do
          invoice = ::Admin::GenerateMonthlyInvoiceService.new(
            contract_id: params[:contract_id],
            month: params[:month],
            year: params[:year]
          ).call

          ok_response(
            data: {
              invoice: MonthlyInvoiceSerializer.new(invoice)
            },
            message: "Đã tạo hóa đơn"
          )
        end

        # ============================================
        # Mark invoice as paid
        # ============================================
        desc "Mark invoice as paid"
        params do
          requires :id, type: Integer, desc: "Invoice ID"
          optional :payment_method, type: String, desc: "Payment method (cash, transfer, etc.)"
          optional :note, type: String, desc: "Payment note"
        end
        patch ":id/pay" do
          invoice = MonthlyInvoice.find(params[:id])

          if invoice.paid?
            error!({ success: false, message: "Hóa đơn đã được thanh toán" }, 422)
          end

          invoice.mark_as_paid!(
            payment_method: params[:payment_method],
            note: params[:note]
          )

          ok_response(
            data: { invoice: MonthlyInvoiceSerializer.new(invoice) },
            message: "Đã thanh toán hóa đơn"
          )
        end

        # ============================================
        # Update invoice adjustment
        # ============================================
        desc "Update invoice adjustment (discount/extra charge)"
        params do
          requires :id, type: Integer, desc: "Invoice ID"
          requires :adjustment, type: Float, desc: "Adjustment amount (positive for extra, negative for discount)"
          optional :adjustment_note, type: String, desc: "Reason for adjustment"
        end
        patch ":id/adjustment" do
          invoice = MonthlyInvoice.find(params[:id])

          if invoice.paid?
            error!({ success: false, message: "Không thể điều chỉnh hóa đơn đã thanh toán" }, 422)
          end

          invoice.update!(
            adjustment: params[:adjustment],
            adjustment_note: params[:adjustment_note]
          )

          ok_response(
            data: {
              invoice: MonthlyInvoiceSerializer.new(invoice),
              new_total: invoice.total_amount
            },
            message: "Đã cập nhật điều chỉnh"
          )
        end

        # ============================================
        # Cancel invoice
        # ============================================
        desc "Cancel invoice"
        params do
          requires :id, type: Integer, desc: "Invoice ID"
          optional :note, type: String, desc: "Cancellation reason"
        end
        patch ":id/cancel" do
          invoice = MonthlyInvoice.find(params[:id])

          if invoice.paid?
            error!({ success: false, message: "Không thể hủy hóa đơn đã thanh toán" }, 422)
          end

          invoice.update!(status: :cancelled, note: params[:note])

          success_response message: "Đã hủy hóa đơn"
        end

        # ============================================
        # Recalculate invoice from readings
        # ============================================
        desc "Recalculate invoice from meter readings"
        params do
          requires :id, type: Integer, desc: "Invoice ID"
        end
        patch ":id/recalculate" do
          invoice = MonthlyInvoice.find(params[:id])

          if invoice.paid?
            error!({ success: false, message: "Không thể tính lại hóa đơn đã thanh toán" }, 422)
          end

          invoice.recalculate_from_readings!

          ok_response(
            data: { invoice: MonthlyInvoiceSerializer.new(invoice) },
            message: "Đã tính lại hóa đơn"
          )
        end

        # ============================================
        # Summary statistics for a period
        # ============================================
        desc "Get invoice summary for a period"
        params do
          requires :month, type: Integer, desc: "Month (1-12)"
          requires :year, type: Integer, desc: "Year"
        end
        get :summary do
          invoices = MonthlyInvoice.for_period(params[:month], params[:year])

          summary = {
            period: "Tháng #{params[:month]}/#{params[:year]}",
            total_invoices: invoices.count,
            total_amount: invoices.sum(:total_amount),
            by_status: {
              pending: invoices.pending.count,
              paid: invoices.paid.count,
              overdue: invoices.overdue.count,
              cancelled: invoices.cancelled.count
            },
            paid_amount: invoices.paid.sum(:total_amount),
            unpaid_amount: invoices.unpaid.sum(:total_amount),
            breakdown: {
              room_fees: invoices.sum(:room_fee),
              electric_fees: invoices.sum(:electric_fee),
              water_fees: invoices.sum(:water_fee),
              service_fees: invoices.sum(:service_fee),
              adjustments: invoices.sum(:adjustment)
            }
          }

          ok_response data: summary
        end
      end
    end
  end
end

