class QuestionsController < ApplicationController
  include Voted
  before_action :authenticate_user!, except: %i[index show]
  before_action :load_question, only: %i[show edit update destroy]

  after_action :publish_question, only: :create

  def index
    @questions = Question.all
  end

  def show
    @answer = Answer.new
    @reward = Reward.new
    @answer.links.new
  end

  def new
    @question = Question.new
    @question.links.new
    @question.build_reward
  end

  def create
    @question = current_user.questions.new(question_params)

    if @question.save
      redirect_to @question, notice: 'Your question was sucessfully created'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if current_user.author_of?(@question)
      # Workaround for rails not to purge existing files
      # when adding new ones through 'Edit'
      @question.files.attach(question_params[:files])
      @question.update(question_params.except(:files))
    end
  end

  def destroy
    # Check if user is authorized to delete the question
    if current_user.author_of?(@question)
      @question.destroy
      redirect_to questions_path, notice: 'Question was successfully deleted'
    else
      redirect_to questions_path, notice: 'Cannot delete the question'
    end
  end

  private

  def load_question
    @question = Question.with_attached_files.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body, files: [], links_attributes: [:id, :name, :url, :_destroy],
                                     reward_attributes: [:name, :image])
  end

  def publish_question
    return if @question.errors.any?

    ActionCable.server.broadcast('questions_channel', {type: 'new question', question: @question})
  end
end
