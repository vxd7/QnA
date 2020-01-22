class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_question, only: %i(create)
  before_action :find_sub, only: :destroy

  authorize_resource

  def create
    @question.subscribe(current_user)
    flash.now['notice'] = 'Successfully subscribed!'
  end

  def destroy
    @question = @subscription.question

    @subscription.destroy
    flash['notice'] = 'Successfully destroyed subscription!'
  end

  private

  def find_question
    @question = Question.find(params[:question_id])
  end

  def find_sub
    @subscription = Subscription.find(params[:id])
  end
end
