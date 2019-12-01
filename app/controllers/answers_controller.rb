class AnswersController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :load_question, only: %i[new create]

  def new
    @answer = @question.answers.new
  end

  def create
    @answer = @question.answers.new(answer_params)

    if @answer.save
      redirect_to @answer, notice: 'Your answer was successfully created'
    else
      render :new
    end
  end

  def show
    @answer = Answer.find(params[:id])
  end

  private

  def answer_params
    params.require(:answer).permit(:body, :author)
  end

  def load_question
    @question = Question.find(params[:question_id])
  end
end

