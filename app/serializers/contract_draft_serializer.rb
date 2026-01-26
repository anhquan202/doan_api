class ContractDraftSerializer < ActiveModel::Serializer
  attributes :id,
             :room_id,
             :current_step,
             :customers_data,
             :supplies_data,
             :utilities_data,
             :start_date,
             :term_months,
             :deposit,
             :status,
             :expires_at,
             :step0_complete,
             :step1_complete,
             :step2_complete,
             :ready_for_completion

  belongs_to :room, serializer: RoomSerializer

  def step0_complete
    object.step0_complete?
  end

  def step1_complete
    object.step1_complete?
  end

  def step2_complete
    object.step2_complete?
  end

  def ready_for_completion
    object.ready_for_completion?
  end
end
