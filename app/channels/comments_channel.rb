class CommentsChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
  end

  def follow(data)
    stream_from "question-#{data['id']}-comments"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def render_comment(data)
    # Use the current_user instance variable getter
    # which we set during connection in
    # app/channels/application_cable/connection.rb
    current_user = self.current_user
    current_user = nil if current_user == 'guest'

    comment = Comment.find(data['id'])
    msg = { 
      type: 'rendered comment', 
      commentable_type: comment.commentable.class.name.downcase,
      commentable_id: comment.commentable.id,
      comment: ApplicationController.render_with_signed_in_user(
                  current_user,
                  partial: 'comments/comment',
                  locals: { comment: comment, resource: comment.commentable }
                )
    }

    transmit(msg)
  end
end
