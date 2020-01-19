class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, only: :index
  authorize_resource

  def create
  end
end
