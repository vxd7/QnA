class Api::V1::QuestionsController < Api::V1::BaseController
  before_action :find_question, only: %i[show update destroy]
  authorize_resource

  def index
    @questions = Question.all
    render json: @questions
  end

  def show
    render json: @question
  end

  def create
    @question = current_user.questions.new(question_params)

    if @question.save
      render json: @question
    else
      render json: {'success': false }
    end
  end

  def update
    if current_user.author_of?(@question)
      @question.update(question_params.except(:files))
    end
  end

  def destroy
    # Check if user is authorized to delete the question
    if current_user.author_of?(@question)
      @question.destroy
    end
  end

  private

  def find_question
    @question = Question.with_attached_files.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body, links_attributes: [:id, :name, :url, :_destroy],
                                     reward_attributes: [:name, :image])
  end
end

