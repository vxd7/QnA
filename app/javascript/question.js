$(document).on('turbolinks:load', function() {
    $('.edit-question-link').on('click', function(e) {
        e.preventDefault();
        $(this).hide();
        var questionId = $(this).data('questionId');
        $('form#edit-question-' + questionId).removeClass('hidden');
    })
});

