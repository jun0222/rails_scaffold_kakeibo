class HealthController < ApplicationController
    def check
      render plain: 'ok'
    end
  end