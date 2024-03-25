import Toybox.Lang;
import Toybox.WatchUi;

// https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/Menu2InputDelegate.html
class ODSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    var id = item.getId();

    if (item instanceof ToggleMenuItem) {
        new Settings().setValue(id, item.isEnabled());
        return;
    }

    if (id.equals("bg")) {
      var colorNames=["White","Lt Gray","Dk Gray","Black","Red","Dk Red","Orange","Yellow","Green","Dk Green","Blue","Dk Blue","Purple","Pink","TRANS"];
      //MySettings.backgroundIdx=(MySettings.backgroundIdx+1)%14;
      item.setSubLabel(colorNames[2]);
      //MySettings.writeKey(MySettings.backgroundKey,MySettings.backgroundIdx);
      //MySettings.background=MySettings.getColor(null,null,null,MySettings.backgroundIdx);
    }
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}
