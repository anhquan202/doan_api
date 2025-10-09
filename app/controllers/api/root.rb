class Api::Root < Grape::API
  prefix :api
  version "v1", using: :path
  format :json

  rescue_from ActiveRecord::RecordInvalid do |e|
    error!({ success: false, message: "Validation failed", errors: e.record.errors.to_hash(true) }, 422)
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    formatted_errors = e.errors.transform_keys { |k| k.join(".") }
    error!({
      success: false,
      message: "Validation failed from Grape",
      errors: formatted_errors
    }, 422)
  end

  rescue_from :all do |e|
    Rails.logger.error "Unhandled exception: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    error!({
      success: false,
      message: e.message
    }, 500)
  end

  helpers do
    def current_admin
      token = headers["Authorization"]&.split(" ")&.last
      return nil unless token
      admin = Warden::JWTAuth::UserDecoder.new.call(token, :admin, nil)

      admin
    rescue => e
      Rails.logger.error "current_user error: #{e.class} - #{e.message}"
      nil
    end

    def authenticate_admin!
      error!("Forbidden", 403) unless current_admin
    end

    def ok_response(data: {}, message: "Success")
      { success: true, message: message, data: data }
    end

    def paginate(collection, per_page: 10)
      pagination = {
        current_page: collection.current_page,
        next_page: collection.next_page,
        prev_page: collection.prev_page,
        total_pages: collection.total_pages,
        total_count: collection.total_count,
        per_page: per_page
      }

      pagination
    end
  end

  mount Api::Admin::Root
end
