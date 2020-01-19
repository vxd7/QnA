class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource

  before_action :find_question, only: %i(create)
  before_action :find_sub, only: :destroy

  def create
    # Do not create subscription if current user has already subscribed to it
    return head :forbidden if @question.subscribed?(current_user)

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
