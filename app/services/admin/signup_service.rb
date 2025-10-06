class Admin::SignupService
  def initialize(params)
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      admin = Admin.create!(@params)

      token = Warden::JWTAuth::UserEncoder.new.call(admin, :admin, nil).first

      token
    end
  rescue ActiveRecord::RecordInvalid => e
    raise e
  rescue => e
    Rails.logger.error "SignupService error: #{e.class} - #{e.message}"
    raise e
  end
end
