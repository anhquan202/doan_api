class CleanupExpiredDraftsJob < ApplicationJob
  queue_as :default

  def perform
    # Mark expired drafts
    ContractDraft.expired.update_all(status: :expired)

    # Optionally delete old expired/cancelled drafts after 7 days
    ContractDraft.where(status: [:expired, :cancelled])
                 .where("updated_at < ?", 7.days.ago)
                 .delete_all
  end
end

