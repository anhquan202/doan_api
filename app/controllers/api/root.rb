class Api::Root < Grape::API
  prefix :api
  version "v1", using: :path
  format :json

  rescue_from ActiveRecord::RecordNotFound do |e|
    error!({
      success: false,
      message: "Record not found"
    }, 404)
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    formatted = {}
    e.record.errors.messages.each do |attr, msgs|
      human = e.record.class.human_attribute_name(attr)
      # remove leading human attribute name from messages (e.g. "Identity code Đã tồn tại" -> "Đã tồn tại")
      text = msgs.map do |m|
        m.to_s.start_with?(human) ? m.to_s.sub(/^#{Regexp.escape(human)}\s*/, "") : m.to_s
      end.join(", ")
      formatted[attr.to_s] = text
    end

    error!({ success: false, message: "Validation failed", errors: formatted }, 422)
  end

  rescue_from ArgumentError do |e|
    error!({ success: false, message: e.message }, 422)
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    formatted_errors = e.errors.each_with_object({}) do |(k, v), memo|
      key = Array(k).join(".").split(".").last
      memo[key] = v.is_a?(Array) ? v.join(", ") : v.to_s
    end

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

    def success_response(message: "Success")
      { success: true, message: message }
    end

    def paginate_meta(collection, per_page = 10)
      {
        current_page: collection.current_page,
        from: collection.offset + 1,
        to: collection.offset + per_page,
        per_page: per_page,
        total: collection.total_entries,
        total_pages: collection.total_pages
      }
    end
  end

  mount Api::Admin::Root
end
