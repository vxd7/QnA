class QuestionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "questions_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def render_question(data)
    # Use the current_user instance variable getter
    # which we set during connection in
    # app/channels/application_cable/connection.rb
    current_user = self.current_user
    current_user = nil if current_user == 'guest'

    msg = { 
      type: 'rendered question', 
      question: ApplicationController.render_with_signed_in_user(
                  current_user,
                  partial: 'questions/question',
                  locals: { question: Question.find(data['id'])}
                )
    }

    transmit(msg)
  end

end
