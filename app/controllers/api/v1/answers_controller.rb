class Api::V1::AnswersController < Api::V1::BaseController
  before_action :find_question, only: %i[index create]
  before_action :find_answer, only: %i[show update destroy]
  authorize_resource

  def index
    @answers = @question.answers
    render json: @answers
  end

  def show
    render json: @answer
  end

  def create
    @answer = @question.answers.new(answer_params)
    @answer.author = current_user

    if @answer.save
      render json: @answer
    else
      render json: @answer.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @answer.update(answer_params.except(:files))
      render json: @answer
    else
      render json: @answer.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    if @answer.destroy
      head :ok
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body, files: [], links_attributes: [:id, :name, :url, :_destroy])
  end

  def find_question
    @question = Question.find(params[:question_id])
  end

  def find_answer
    @answer = Answer.with_attached_files.find(params[:id])
  end
end
