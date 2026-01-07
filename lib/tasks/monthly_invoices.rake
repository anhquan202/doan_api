namespace :monthly_invoices do
  desc "Create monthly invoices from all existing readings"
  task create_from_readings: :environment do
    puts "🔄 Starting monthly invoices creation from readings..."

    created_count = 0
    skipped_count = 0
    error_count = 0

    # Get all unique combinations of contract_id, month, year from readings
    electric_periods = ElectricReading.pluck(:contract_id, :month, :year).uniq
    water_periods = WaterReading.pluck(:contract_id, :month, :year).uniq
    all_periods = (electric_periods + water_periods).uniq

    puts "📊 Found #{all_periods.length} unique period(s) across all readings"

    all_periods.each do |contract_id, month, year|
      begin
        contract = Contract.find_by(id: contract_id)
        unless contract
          puts "⚠️  Contract #{contract_id} not found, skipping..."
          skipped_count += 1
          next
        end

        # Check if invoice already exists
        invoice = MonthlyInvoice.find_by(contract_id: contract_id, month: month, year: year)

        if invoice
          puts "⏭️  Invoice already exists for Contract #{contract_id} (#{month}/#{year}), skipping..."
          skipped_count += 1
          next
        end

        # Get readings for this period
        electric_reading = ElectricReading.find_by(contract_id: contract_id, month: month, year: year)
        water_reading = WaterReading.find_by(contract_id: contract_id, month: month, year: year)

        # Fetch room fee from contract's room
        room_fee = contract.room&.price || 0

        # Create invoice
        new_invoice = MonthlyInvoice.create!(
          contract_id: contract_id,
          month: month,
          year: year,
          room_fee: room_fee,
          electric_fee: electric_reading&.total_fee || 0,
          water_fee: water_reading&.total_fee || 0,
          service_fee: 0,
          service_details: {},
          adjustment: 0,
          adjustment_note: nil,
          status: :pending
        )

        created_count += 1
        puts "✅ Created invoice for Contract #{contract_id} (#{month}/#{year}) - Total: #{new_invoice.total_amount}"
      rescue StandardError => e
        error_count += 1
        puts "❌ Error creating invoice for Contract #{contract_id} (#{month}/#{year}): #{e.message}"
      end
    end

    puts "\n📈 Summary:"
    puts "   Created: #{created_count}"
    puts "   Skipped: #{skipped_count}"
    puts "   Errors:  #{error_count}"
    puts "✨ Task completed!"
  end

  desc "Recalculate all monthly invoices from current readings"
  task update_all: :environment do
    puts "🔄 Starting monthly invoices recalculation..."

    updated_count = 0
    error_count = 0

    MonthlyInvoice.find_each do |invoice|
      begin
        invoice.recalculate_from_readings!
        updated_count += 1
        puts "✅ Updated invoice for Contract #{invoice.contract_id} (#{invoice.month}/#{invoice.year}) - Total: #{invoice.total_amount}"
      rescue StandardError => e
        error_count += 1
        puts "❌ Error updating invoice #{invoice.id}: #{e.message}"
      end
    end

    puts "\n📈 Summary:"
    puts "   Updated: #{updated_count}"
    puts "   Errors:  #{error_count}"
    puts "✨ Task completed!"
  end

  desc "Delete all monthly invoices (warning: destructive)"
  task clear_all: :environment do
    if ENV["FORCE"].blank?
      puts "⚠️  This will DELETE all monthly invoices!"
      puts "Run with FORCE=true to confirm: rake monthly_invoices:clear_all FORCE=true"
      exit
    end

    count = MonthlyInvoice.count
    MonthlyInvoice.delete_all
    puts "🗑️  Deleted #{count} invoices"
  end

  desc "Show monthly invoices statistics"
  task stats: :environment do
    total = MonthlyInvoice.count
    by_status = MonthlyInvoice.group(:status).count
    by_contract = MonthlyInvoice.group(:contract_id).count

    puts "\n📊 Monthly Invoices Statistics"
    puts "=" * 50
    puts "Total invoices: #{total}"
    puts "\nBy Status:"
    by_status.each do |status, count|
      puts "  #{status}: #{count}"
    end
    puts "\nTop 10 Contracts by Invoice Count:"
    by_contract.sort_by { |_k, v| -v }.first(10).each do |contract_id, count|
      contract = Contract.find_by(id: contract_id)
      code = contract&.contract_code || "N/A"
      puts "  Contract #{contract_id} (#{code}): #{count} invoices"
    end
    puts "=" * 50
  end
end
