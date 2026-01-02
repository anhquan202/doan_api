module Admin
  module ContractWizard
    # Cancel a draft - can be called anytime before completion
    class CancelDraftService
      def initialize(params)
        @draft_id = params[:draft_id]
      end

      def call
        draft = ContractDraft.active.find(@draft_id)
        draft.update!(status: :cancelled)
        true
      end
    end
  end
end

