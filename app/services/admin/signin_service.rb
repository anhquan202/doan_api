class Admin::SigninService
  def initialize(params)
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      admin = Admin.find_by(email: @params[:email])

      unless admin&.valid_password?(@params[:password])
        raise StandardError, "Invalid password"
      end

      token = Warden::JWTAuth::UserEncoder.new.call(admin, :admin, nil).first

      token
    end
  end
end
