INcrawler.ui.Tab = function() {
  // Class Variables

  // Constructor
  var init  = function(element) {
    //Instance Variables
    var active_tab = $(element).find('.tab.active');

    //Instance Methods
    var switchToTab = function(tab) {
      $('#'+active_tab.data('tab')).hide();
      active_tab.toggleClass('active');

      active_tab = $(tab);
      active_tab.toggleClass('active');
      $('#'+active_tab.data('tab')).show();
    }

    var getActiveTab = function() {
      return active_tab;
    }

    // Constructor Method Body
    $(element).find('.tab').on('click', function(){
      switchToTab(this);
    });


    // Return Object
    return {
      getActiveTab: getActiveTab,
      switchToTab: switchToTab
    }
  }

  // Class Methods

  // Return Class
  return {
    init: init
  };
}();
