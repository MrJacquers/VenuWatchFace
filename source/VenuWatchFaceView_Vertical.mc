import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
//import Toybox.Complications;

class VenuWatchFaceView_Vertical extends WatchUi.WatchFace {  
  var _blanked = false;
  var _lowPwrMode = false;
  
  var _font;
  var _timeFont;
  var _hourColor;

  var _hrIcon;

  // if using complication to get hr
  //var _hrId;
  //var _curHr;

  function initialize() {
    System.println("view initialize");
    WatchFace.initialize();

    _font = WatchUi.loadResource(Rez.Fonts.id_robotomono36);
    _timeFont = WatchUi.loadResource(Rez.Fonts.id_monofonto_outline);
    _hrIcon = Application.loadResource(Rez.Drawables.HRIcon) as BitmapResource;

    // https://developer.garmin.com/connect-iq/api-docs/Toybox/System/DeviceSettings.html
    /*var settings = System.getDeviceSettings();
    if (settings has :requiresBurnInProtection) {
      var canBurn = settings.requiresBurnInProtection;
      System.println("canBurnIn:" + canBurn);
    }*/


    // https://developer.garmin.com/connect-iq/core-topics/complications/
    // https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html
    /*if (Toybox has :Complications) {
      Complications.registerComplicationChangeCallback(self.method(:onComplicationChanged));
      _hrId = new Id(Complications.COMPLICATION_TYPE_HEART_RATE);
    }*/
  }

  /*function onComplicationChanged(id as Complications.Id) as Void {
    System.println("onComplicationChanged");
    if (id.equals(_hrId)) {
      _curHr = Complications.getComplication(id).value;
      System.println(_curHr);
    }
  }*/

  function loadSettings() {
    // https://developer.garmin.com/connect-iq/core-topics/properties-and-app-settings/
    if (Toybox.Application has :Properties) {
      _hourColor = Application.Properties.getValue("HourColor") as Number;
    }
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    System.println("onLayout");
    System.println("width: " + dc.getWidth());
  }

  // Called when this View is brought to the foreground.
  // Restore the state of this View and prepare it to be shown.
  // This includes loading resources into memory.
  function onShow() as Void {
    System.println("onShow");    
    _lowPwrMode = false;
    /*if (_hrId != null) {
      Complications.subscribeToUpdates(_hrId);
    }*/
  }

  // Updates the view.
  // Called every second in high power mode.
  // Called once a minute in low power mode.
  function onUpdate(dc as Dc) as Void {
    System.print("onUpdate: ");

    if (_lowPwrMode) {
      System.println("low power mode");
      // The firmware will blank the screen if AOD is turned off
      /*if (_blanked == false) {
        // Clear screen, for AOD display
        dc.setColor(0, 0);
        dc.clear();
      }*/
      return;
    }
    
    System.println("drawing");

    // clear screen
    dc.setColor(0, 0);
    dc.clear();

    //dc.setColor(Graphics.COLOR_BLUE, 0);
    //dc.drawLine(0, 104, 412, 312);
    //dc.drawLine(0, 312, 412, 104);

    // lines for positioning
    /*var i = 0;
    do {
      i+=13;
      if (i==208) {
        dc.setColor(Graphics.COLOR_LT_GRAY, -1);
      } else {
        dc.setColor(Graphics.COLOR_DK_GRAY, -1);
      }
      dc.drawLine(0, i, 416, i); // horizontal line
      dc.drawLine(i, 0, i, 416); // vertical line
      //dc.drawCircle(208,208,i);  // x,y,r
    } while (i < 416);*/

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

    // date
    dc.setColor(Graphics.COLOR_LT_GRAY, -1);
    dc.drawText(212, 52, _font, getDate(dateInfo), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // connection status
    dc.setColor(_hourColor, -1);
    var cs = System.getDeviceSettings().phoneConnected ? "B" : "";
    dc.drawText(24, 210, _font, cs, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    // hour
    dc.drawText(200, 92, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT);

    // minutes
    dc.setColor(Graphics.COLOR_LT_GRAY, -1);
    dc.drawText(200, 216, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT);

    // seconds
    //dc.setColor(_hourColor, -1);
    //dc.drawText(208, 308, _font, dateInfo.sec.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    // heartrate
    var statsX = 260;
    //dc.drawBitmap(220, 104, _hrIcon);
    //dc.setColor(Graphics.COLOR_LT_GRAY, -1);
    dc.drawText(statsX, 112, _font, getHeartRateAI(), Graphics.TEXT_JUSTIFY_LEFT);

    // body battery
    dc.drawText(statsX, 164, _font, getBodyBattery(), Graphics.TEXT_JUSTIFY_LEFT);

    // steps
    //dc.setColor(Graphics.COLOR_LT_GRAY, -1);
    dc.drawText(statsX, 218, _font, getSteps(), Graphics.TEXT_JUSTIFY_LEFT);

    // temperature
    dc.drawText(statsX, 270, _font, getTemperature(), Graphics.TEXT_JUSTIFY_LEFT);

    // battery
    dc.drawText(208, 366, _font, getBattery(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  private function getDate(dateInfo) {
    return Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week, dateInfo.month, dateInfo.day]);
  }

  private function getTime(dateInfo) {
    return Lang.format("$1$:$2$", [dateInfo.hour.format("%02d"), dateInfo.min.format("%02d")]);
    //var clockTime = System.getClockTime();
    //return Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
  }
  
  private function getHeartRateAI() {
    var hr = Activity.getActivityInfo().currentHeartRate;
    if (hr != null && hr != 0 && hr != 255) {
      return hr;
    }
    return "00";
  }

  /*private function getHeartRateComp() {
   if (_hrId != null && _curHr != null) {
      System.println("hr from complication");
      return;
    }
    _curHr = "--";
  }*/

  private function getHeartRateHist() {
    var sample = ActivityMonitor.getHeartRateHistory(1, true).next();
    if (sample != null && sample.heartRate != null) {
      return "[" + sample.heartRate + "]";
    }
    return "--";
  }
  
  private function getBodyBattery() {
    // https://developer.garmin.com/connect-iq/api-docs/Toybox/SensorHistory.html
    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
      var history  = Toybox.SensorHistory.getBodyBatteryHistory({:period=>1,:order=>Toybox.SensorHistory.ORDER_NEWEST_FIRST});
      var sample = history.next();
      if (sample != null && sample.data != null && sample.data >=0 && sample.data <= 100) {
        return sample.data.format("%02d") + "%";
      }
    }
    return "--";
  }

  private function getStress() {
    // https://developer.garmin.com/connect-iq/api-docs/Toybox/SensorHistory.html
    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getStressHistory)) {
      var history  = Toybox.SensorHistory.getStressHistory({:period=>1,:order=>Toybox.SensorHistory.ORDER_NEWEST_FIRST});
      var sample = history.next();
      if (sample != null && sample.data != null && sample.data >=0 && sample.data <= 100) {
        return sample.data.format("%02d") + "%";
      }
    }
    return "--";
  }

  private function getSteps() {
    var info = ActivityMonitor.getInfo();
    return info.steps;
  }

  private function getTemperature() {    
    // Check device for SensorHistory compatibility
    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
        // Set up the method with parameters
       var iterator = Toybox.SensorHistory.getTemperatureHistory({:period=>1,:order=>Toybox.SensorHistory.ORDER_NEWEST_FIRST});
       var sample = iterator.next();
       if (sample != null && sample.data != null) {
        return sample.data.format("%d") + "°";
       }
    }
    return "--";
  }

  private function getBattery() {
    var battery = System.getSystemStats().battery;
    return Lang.format("$1$%", [battery.format("%02d")]);
    //return battery.format("%02d") + "%";
  }  

  // Called when this View is removed from the screen. Save the state of this View here.
  // This includes freeing resources from memory.
  function onHide() as Void {
    System.println("onHide");
    //Complications.unsubscribeFromAllUpdates();
  }

  // Terminate any active timers and prepare for slow updates (once a minute).
  function onEnterSleep() as Void {
    System.println("onEnterSleep");
    //Complications.unsubscribeFromAllUpdates();
    _lowPwrMode = true;
    _blanked = false;
    //WatchUi.requestUpdate();
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    System.println("onExitSleep");
    _lowPwrMode = false;
    //WatchUi.requestUpdate();
    /*if (_hrId != null) {
      Complications.subscribeToUpdates(_hrId);
    }*/
  }
}

// https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html
// https://developer.garmin.com/connect-iq/api-docs/Toybox/SensorHistory.html#getHeartRateHistory-instance_function
// https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityMonitor.html
// https://forums.garmin.com/developer/connect-iq/f/discussion/6267/performances-dos-and-donts
// https://github.com/AndrewKhassapov/connect-iq
// https://forums.garmin.com/developer/connect-iq/f/discussion/248284/help-with-bitmap-watchface-digital-display-or-analog-display/1181718
// https://forums.garmin.com/developer/connect-iq/f/discussion/249947/port-from-direct-draw-to-layout
// https://forums.garmin.com/developer/connect-iq/f/discussion/2768/datafields-best-practices-for-using-layouts-should-i-use-layouts-at-all
// https://mharwood.uk/creating-a-simple-garmin-watch-face/
// https://forums.garmin.com/developer/connect-iq/f/discussion/7961/overview-of-connect-iq-apps-accompanied-with-source-code
// https://kaihao.dev/posts/Develop-a-Garmin-watch-face
// https://forums.garmin.com/developer/connect-iq/f/discussion/315443/here-are-a-few-complication-samples/1696417