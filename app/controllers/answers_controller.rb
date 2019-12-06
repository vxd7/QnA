class AnswersController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :load_question, only: %i[new create]
  before_action :load_answer, only: %i[destroy update]

  def new
    @answer = @question.answers.new
    @answer.author = current_user
  end

  def create
    @answer = @question.answers.new(answer_params)
    @answer.author = current_user
    @answer.save

    # if @answer.save
    #   redirect_to @answer, notice: 'Your answer was successfully created'
    # else
    #   render :new
    # end
  end

  def show
    @answer = Answer.find(params[:id])
  end

  def destroy
    # Check if user is authorized to delete the question
    if current_user.author_of?(@answer)
      @answer.destroy
      redirect_to question_path(@answer.question), notice: 'Answer was successfully deleted'
    else
      redirect_to question_path(@answer.question), notice: 'Cannot delete the answer'
    end
  end

  def update
    @answer.update(answer_params)
    @question = @answer.question
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end

  def load_question
    @question = Question.find(params[:question_id])
  end

  def load_answer
    @answer = Answer.find(params[:id])
  end
end
