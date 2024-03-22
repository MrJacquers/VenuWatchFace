import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
//import Toybox.Complications;

class VenuWatchFaceView extends WatchUi.WatchFace {  
  var _devSize;
  var _devCenter;
  var _timeFont;
  var _hidden = false;
  var _blanked = false;
  var _lowPwrMode = false;

  // TODO: put in settings
  var _hourColor;
  var _minuteColor;
  var _appAODEnabled = false;

  // if using complication to get hr
  //var _hrId;
  //var _curHr;

  function initialize() {
    System.println("view initialize");
    WatchFace.initialize();

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

  // keeping as example
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
      _minuteColor = Application.Properties.getValue("MinuteColor") as Number;
    }
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    System.println("onLayout");
    _devSize = dc.getWidth();
    _devCenter = _devSize / 2;
    _timeFont = WatchUi.loadResource(Rez.Fonts.id_teko_bold_outline);
  }

  // Called when this View is brought to the foreground.
  // Restore the state of this View and prepare it to be shown.
  // This includes loading resources into memory.
  function onShow() as Void {
    System.println("onShow");
    _hidden = false;
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

    if (_hidden) {
      System.println("hidden");
      return;
    }
    
    if (_lowPwrMode) {
      System.println("low power mode");
      drawScreenSaver(dc);
      return;
    }

    System.println("drawing");

    clearScreen(dc);

    //dc.setColor(Graphics.COLOR_BLUE, 0);
    //dc.drawLine(0, 104, 412, 312);
    //dc.drawLine(0, 312, 412, 104);

    // lines for positioning
    //drawGrid(dc);

    //dc.setColor(Graphics.COLOR_YELLOW, 0);
    //dc.fillRoundedRectangle(118, 32, 182, 44, 5);

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

    // date
    dc.setColor(Graphics.COLOR_LT_GRAY, -1);
    dc.drawText(212, 52, Graphics.FONT_SMALL, getDate(dateInfo), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // connection status
    dc.setColor(_hourColor, -1);
    var cs = System.getDeviceSettings().phoneConnected ? "B" : "";
    dc.drawText(32, 210, Graphics.FONT_TINY, cs, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    // hour
    dc.setColor(_hourColor, -1);
    dc.drawText(200, 206, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

    // minutes
    dc.setColor(_minuteColor, -1);
    dc.drawText(216, 206, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    // seconds
    dc.setColor(_hourColor, -1);
    dc.drawText(376, 156, Graphics.FONT_TINY, dateInfo.sec.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

    // something
    //dc.setColor(Graphics.COLOR_DK_GRAY, -1);
    //dc.drawText(104, 108, Graphics.FONT_TINY, "xx", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // heartrate
    dc.setColor(Graphics.COLOR_RED, -1);
    dc.drawText(_devCenter, 108, Graphics.FONT_TINY, getHeartRateAI(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // something else
    //dc.setColor(Graphics.COLOR_DK_GRAY, -1);
    //dc.drawText(312, 108, Graphics.FONT_TINY, "yy", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // body battery
    dc.setColor(Graphics.COLOR_LT_GRAY, -1);
    dc.drawText(104, 312, Graphics.FONT_TINY, getBodyBattery(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // steps
    dc.drawText(_devCenter, 312, Graphics.FONT_TINY, getSteps(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // temperature
    dc.drawText(312, 312, Graphics.FONT_TINY, getTemperature(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // battery
    dc.drawText(_devCenter, 376, Graphics.FONT_TINY, getBattery(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // circles
    //dc.setColor(Graphics.COLOR_DK_GRAY, 0);
    //dc.drawCircle(_devCenter,_devCenter,204);

    /*dc.setColor(_hourColor, -1);
    var top=90;
    var secs = top + (360 - (dateInfo.sec * 6));
     if(secs > 360) {
      secs = secs - 360;
    }
    dc.drawArc(_devCenter, _devCenter, 204, Graphics.ARC_CLOCKWISE , top, secs);*/

    //drawSecDot(dc, dateInfo.sec);
  }

  function clearScreen(dc as Dc) {
    dc.setColor(0, 0);
    dc.clear();
  }

  // for layout position debugging
  function drawGrid(dc as Dc) {
    var i = 0;
    var step = 13;

    do {
      i += step;
      if (i == _devCenter) {
        dc.setColor(Graphics.COLOR_LT_GRAY, -1);
      } else {
        dc.setColor(Graphics.COLOR_DK_GRAY, -1);
      }
      dc.drawLine(0, i, _devSize, i); // horizontal line
      dc.drawLine(i, 0, i, _devSize); // vertical line
      //dc.drawCircle(_devCenter,_devCenter,i);  // x,y,r
    } while (i < _devSize);
  }

  function drawScreenSaver(dc as Dc) {
    if (_appAODEnabled == false) {
      // The watch OS will blank the screen if system AOD is turned off, but this is safer, just in case.
      if (_blanked == false) {
        clearScreen(dc);
        _blanked = true;
      }
      return;
    }

    System.println("drawScreenSaver");

    clearScreen(dc);
    
    //drawSecDot(dc, time.sec);
    var radius = 160;
    var time = System.getClockTime();
    var timeString = Lang.format("$1$:$2$", [time.hour.format("%02d"), time.min.format("%02d")]);

    dc.setColor(Graphics.COLOR_DK_GRAY, 0);
    var angle = (time.min / 60.0) * Math.PI * 2;
    var xh = radius * Math.sin(angle);
    var yh = -radius * Math.cos(angle);
    dc.drawText(xh + _devCenter, yh + _devCenter, Graphics.FONT_TINY, timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  // https://forums.garmin.com/developer/connect-iq/f/discussion/1740/better-code-needed-for-hands-on-watchface/19026
  private function drawSecDot(dc, sec) {
    dc.setColor(_hourColor, -1);
    var angle = (sec / 60.0) * Math.PI * 2;
    var xh = (_devCenter-5) * Math.sin(angle); // _devCenter=radius
    var yh = -(_devCenter-5) * Math.cos(angle); // _devCenter=radius
    dc.fillCircle(xh + _devCenter, yh + _devCenter, 4); // _devCenter=centerpoint
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
    return "--";
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
    _hidden = true;
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