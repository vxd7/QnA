$(document).on('turbolinks:load', function() {
  $('.votes-links').on('ajax:success', handleVoteAjax);
});

function handleVoteAjax(e) {
  var resource = e.detail[0];

  var resourceId = resource.id;
  var resourceType = resource.resource_type.toLowerCase();
  var resourceRating = resource.rating;

  var ratingSelector = '#' + resourceType + '-' + resourceId + '-votes ' + '.rating'
  $(ratingSelector).text('Rating: ' + resourceRating);
}
