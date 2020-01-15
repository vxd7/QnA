class Api::V1::AnswersController < Api::V1::BaseController
  before_action :find_question, only: :index
  before_action :find_answer, only: :show
  authorize_resource class: false

  def index
    @answers = @question.answers
    render json: @answers
  end

  def show
    render json: @answer
  end

  private

  def find_question
    @question = Question.find(params[:question_id])
  end

  def find_answer
    @answer = Answer.with_attached_files.find(params[:id])
  end
end
