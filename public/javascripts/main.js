// Changes what's active on the navbar
$(document).ready(function() {
  $('a[href="' + this.location.pathname + '"]').parents('li,ul').addClass('active');
});

function showLoading() {
  $('#cover-spin').show(0);
}
