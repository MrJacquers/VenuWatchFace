import Toybox.Lang;
import Toybox.WatchUi;

// https://developer.garmin.com/connect-iq/core-topics/native-controls/
class ODSettingsMenu extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize(null);

    Menu2.setTitle("Settings");

    var settings = new Settings();    
    Menu2.addItem(new WatchUi.ToggleMenuItem("AOD Mode", null, "AODModeEnabled", settings.getValue("AODModeEnabled", false), null));
    Menu2.addItem(new WatchUi.ToggleMenuItem("Show Grid", null, "GridEnabled", settings.getValue("GridEnabled", false), null));

    // https://forums.garmin.com/developer/connect-iq/f/discussion/264671/menu2-multiple-options-select-item
    // https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/CustomMenu.html
    var colorNames=["White","Lt Gray","Dk Gray","Black","Red","Dk Red","Orange","Yellow","Green","Dk Green","Blue","Dk Blue","Purple","Pink","TRANS"];
    Menu2.addItem(new WatchUi.MenuItem("Background Color", colorNames[0], "bg", {}));
  }
}
