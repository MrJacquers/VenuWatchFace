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
  }
}
