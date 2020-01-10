import consumer from "./consumer"

consumer.subscriptions.create("QuestionsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    if($('.questions-list').length == 0) {
      return;
    }

    // Called when there's incoming data on the websocket for this channel
    if(data['type'] == 'new question') {
      //console.log('new question', data['question']);
      this.perform('render_question', data['question']);
    } else if (data['type'] == 'rendered question') {
      //console.log('rendered question', data['question']);
      $('.questions-list').append(data['question']);
    }
  }
});
