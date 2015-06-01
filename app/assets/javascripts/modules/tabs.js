INcrawler.ui.tabs = function() {
  var init  = function(element) {
    $(element).find('.tab').on('click', function(){
      switchToTab(this);
    });
  }

  var switchToTab = function(tab) {
    var active_tab = $(tab).parent().find('.active');
    $('#'+active_tab.data('tab')).hide();
    active_tab.toggleClass('active');

    $(tab).toggleClass('active');
    $('#'+$(tab).data('tab')).show();
  }

  return {
    init: init,
    switchToTab: switchToTab
  };
}();
