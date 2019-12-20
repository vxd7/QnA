class RewardsController < ApplicationController
  before_action :authenticate_user!, only: :index

  def index
    @rewards = Reward.all
  end
end
