class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_commentable, only: :create

  after_action :publish_comment, only: :create

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.commentable = @commentable
    @comment.save
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def find_commentable
    commentable_param = params.keys.find { |key| key.match(/_id$/) }
    @commentable = commentable_param.match(/^[^\_]*/).to_s.singularize.classify.constantize.find(params[commentable_param])
  end

  def publish_comment
  end
end
