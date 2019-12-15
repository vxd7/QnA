class AnswersController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :load_question, only: %i[new create]
  before_action :load_answer, only: %i[destroy update mark_best]

  def new
    @answer = @question.answers.new
    @answer.author = current_user
  end

  def create
    @answer = @question.answers.new(answer_params)
    @answer.author = current_user
    @answer.save
  end

  def show
    @answer = Answer.find(params[:id])
  end

  def destroy
    # Check if user is authorized to delete the question
    if current_user.author_of?(@answer)
      @answer.destroy
    end
  end

  def update
    if current_user.author_of?(@answer)
      # Workaround for rails not to purge existing files
      # when adding new ones through 'Edit'
      @answer.files.attach(answer_params[:files])
      @answer.update(answer_params.except(:files))
    end
  end

  def mark_best
    if current_user.author_of?(@answer.question)
      @answer.mark_best
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body, files: [])
  end

  def load_question
    @question = Question.find(params[:question_id])
  end

  def load_answer
    @answer = Answer.with_attached_files.find(params[:id])
  end
end
