$(document).ready(function() {
  $('.tab').on('click', function(){
    var active_tab = $(this).parent().find('.active');
    $('#'+active_tab.data('tab')).hide();
    active_tab.toggleClass('active');

    $(this).toggleClass('active');
    $('#'+$(this).data('tab')).show();
  });
});
