class AnswersChannel < ApplicationCable::Channel
  def subscribed
  end

  def follow(data)
    stream_from "question-#{data['id']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def render_answer(data)
    # Use the current_user instance variable getter
    # which we set during connection in
    # app/channels/application_cable/connection.rb
    current_user = self.current_user
    current_user = nil if current_user == 'guest'

    msg = { 
      type: 'rendered answer', 
      answer: ApplicationController.render_with_signed_in_user(
                  current_user,
                  partial: 'answers/answer',
                  locals: { answer: Answer.find(data['id'])}
                )
    }

    transmit(msg)
  end
end
