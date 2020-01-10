import consumer from "./consumer"

consumer.subscriptions.create("AnswersChannel", {
  connected() {
    // Called when the subscription is ready for use on the server

    // If we are currently on the question's page
    // with answers listing div
    if($('.answers').length > 0) {
      // Get question id from div id on page
      var questionId = $('div').filter(function() {
        return this.id.match(/question-[\d]{1,}/);
      }).attr('id').split('-')[1];

      // And subscribe to the question-id stream
      this.perform('follow', { id: questionId });
    }
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    if(data['type'] == 'new answer') {
      this.perform('render_answer', data['answer']);
    } else if (data['type'] == 'rendered answer') {
      $('.answers').append(data['answer']);
    }
  }
});
