# frozen_string_literal: true

module WellKnown
  class ProtocolHandlerController < ActionController::Base # rubocop:disable Rails/ApplicationController

    before_action :set_target
    before_action :target_acceptable?

    rescue_from ActionController::ParameterMissing, with: :bad_request

    def show
      redirect_to authorize_interaction_path(uri: @target.sub("web+ap", "https"))
    end

    private

    def set_target
      @target = target_param
    end

    # NOTE: supports "probing"
    def target_acceptable?
      # FIXME: this should be web+ap: but doing it this way avoids issues in
      # the short term... revisit this once web+ap:foo... is being used in
      # addition to web+ap://example/...
      return if @target.starts_with? "web+ap://"
      not_found
    end

    def target_param
      params.require(:target)
    end

    def bad_request
      expires_in(3.minutes, public: true)
      head 400
    end

    def not_found
      expires_in(3.minutes, public: true)
      head 404
    end
  end
end
