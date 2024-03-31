import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class VenuWatchFaceView extends WatchUi.WatchFace {  
  var _devSize;
  var _devCenter;
  var _timeFont;
  var _blanked = false;
  var _lowPwrMode = false;
  var _settings;
  var _dataFields;
  
  function initialize() {
    //System.println("view initialize");
    WatchFace.initialize();
    
    _settings = new Settings();
    loadSettings();
    
    _dataFields = new DataFields();

    // https://developer.garmin.com/connect-iq/api-docs/Toybox/System/DeviceSettings.html
    /*var settings = System.getDeviceSettings();
    if (settings has :requiresBurnInProtection) {
      var canBurn = settings.requiresBurnInProtection;
      //System.println("canBurnIn:" + canBurn);
    }*/    
  }

  function loadSettings() {
    _settings.loadSettings();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    //System.println("onLayout");
    _devSize = dc.getWidth();
    _devCenter = _devSize / 2;
    _timeFont = WatchUi.loadResource(Rez.Fonts.id_monofonto_outline);
  }

  // Called when this View is brought to the foreground.
  // Restore the state of this View and prepare it to be shown.
  // This includes loading resources into memory.
  function onShow() as Void {
    //System.println("onShow");
    //loadSettings();
    _lowPwrMode = false;

    /*if (_hrId != null) {
      Complications.subscribeToUpdates(_hrId);
    }*/
  }

  // Updates the view.
  // Called every second in high power mode.
  // Called once a minute in low power mode.
  function onUpdate(dc as Dc) as Void {
    //System.print("onUpdate: ");

    if (_lowPwrMode) {
      //System.println("low power mode");
      drawScreenSaver(dc);
      return;
    }

    //System.println("drawing");

    clearScreen(dc);

    //dc.setColor(Graphics.COLOR_BLUE, 0);
    //dc.drawLine(0, 104, 412, 312);
    //dc.drawLine(0, 312, 412, 104);

    // lines for positioning
    if (_settings.showGrid) {
      drawGrid(dc);
    }

    //dc.setColor(Graphics.COLOR_YELLOW, 0);
    //dc.fillRoundedRectangle(118, 32, 182, 44, 5);

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

    // date
    dc.setColor(_settings.dateColor, -1);
    dc.drawText(212, 52, Graphics.FONT_SMALL, _dataFields.getDate(dateInfo), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // something
    //dc.setColor(Graphics.COLOR_DK_GRAY, -1);
    //dc.drawText(104, 108, Graphics.FONT_TINY, "xx", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    
    // heartrate
    dc.setColor(_settings.hrColor, -1);
    dc.drawText(_devCenter, 108, Graphics.FONT_TINY, _dataFields.getHeartRateAI(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // something else
    //dc.setColor(Graphics.COLOR_DK_GRAY, -1);
    //dc.drawText(312, 108, Graphics.FONT_TINY, "yy", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // connection status
    dc.setColor(_settings.connectColor, -1);
    var cs = System.getDeviceSettings().phoneConnected ? "B" : "";
    dc.drawText(30, 208, Graphics.FONT_TINY, cs, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    // hour
    dc.setColor(_settings.hourColor, -1);
    dc.drawText(200, 206, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

    // minutes
    dc.setColor(_settings.minuteColor, -1);
    dc.drawText(216, 206, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    // seconds
    dc.setColor(_settings.secColor, -1);
    dc.drawText(378, 148, Graphics.FONT_TINY, dateInfo.sec.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
    
    // stress
    dc.setColor(_settings.bodyBattColor, -1);
    dc.drawText(104, 312, Graphics.FONT_TINY, _dataFields.getStress(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // steps
    dc.setColor(_settings.stepsColor, -1);
    dc.drawText(_devCenter, 312, Graphics.FONT_TINY, _dataFields.getSteps(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // temperature
    dc.setColor(_settings.tempColor, -1);
    dc.drawText(312, 312, Graphics.FONT_TINY, _dataFields.getTemperature(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // battery
    dc.setColor(_settings.battColor, -1);
    dc.drawText(_devCenter, 376, Graphics.FONT_TINY, _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    //_dataFields.drawBoxes(dc);

    // circles
    //dc.setPenWidth(1);
    //dc.setColor(Graphics.COLOR_DK_GRAY, 0);
    //dc.drawCircle(_devCenter,_devCenter,204);

    /*dc.setColor(_hourColor, -1);
    var top = 90;
    var secs = top + (360 - (dateInfo.sec * 6));
     if (secs > 360) {
      secs = secs - 360;
    }
    dc.setPenWidth(4);
    dc.drawArc(_devCenter, _devCenter, 204, Graphics.ARC_CLOCKWISE , top, secs);*/

    //drawSecDot(dc, dateInfo.sec);
    //drawSecDot2(dc, dateInfo.sec);

    /*var sec = 0;
    do {
      //drawSecDot(dc, sec, _devCenter);
      drawSecDot2(dc, sec, _devCenter);
      sec += 5;
    } while (sec < 60);*/
  }

  private function clearScreen(dc as Dc) {
    dc.setColor(0, 0);
    dc.clear();
  }

  // for layout position debugging
  private function drawGrid(dc as Dc) {
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

  private function drawScreenSaver(dc as Dc) {
    if (_settings.appAODEnabled == false) {
      // The watch OS will blank the screen if system AOD is turned off.
      /*if (_blanked == false) {
        clearScreen(dc);
        _blanked = true;
      }*/
      return;
    }

    //System.println("drawScreenSaver");

    clearScreen(dc);
    
    //drawSecDot(dc, time.sec);
    var radius = 160;
    var time = System.getClockTime();
    var timeString = Lang.format("$1$:$2$", [time.hour.format("%02d"), time.min.format("%02d")]);

    dc.setColor(Graphics.COLOR_DK_GRAY, 0);
    var rad = (time.min / 60.0) * Math.PI * 2;
    var x = radius * Math.sin(rad) + 0.5;
    var y = -radius * Math.cos(rad);
    dc.drawText(x + _devCenter, y + _devCenter, Graphics.FONT_TINY, timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  // https://forums.garmin.com/developer/connect-iq/f/discussion/1740/better-code-needed-for-hands-on-watchface/19026
  private function drawSecDot(dc, sec, radius) {
    var angle = (sec / 60.0) * Math.PI * 2;
    var x = Math.sin(angle) * radius + 0.5;
    var y = Math.cos(angle) * -radius;

    dc.drawLine(_devCenter, _devCenter, x + _devCenter, y + _devCenter);
    //dc.fillCircle(x + _devCenter, y + _devCenter, 8);
  }

  // https://github.com/bombsimon/garmin-seaside
  private function drawSecDot2(dc, sec, radius) {
    //dc.setColor(Graphics.COLOR_WHITE, -1);
    //var angle = Math.toRadians((sec * 6 + 270));
    var angle = (sec * 6 + 270) * (Math.PI / 180);
    var x = Math.cos(angle) * radius;
    var y = Math.sin(angle) * radius;

    dc.drawLine(_devCenter, _devCenter, x + _devCenter, y + _devCenter);
    //dc.fillCircle(x + _devCenter, y + _devCenter, 8);
  }

  // Called when this View is removed from the screen. Save the state of this View here.
  // This includes freeing resources from memory.
  function onHide() as Void {
    //System.println("onHide");
    //Complications.unsubscribeFromAllUpdates();
  }

  // Terminate any active timers and prepare for slow updates (once a minute).
  function onEnterSleep() as Void {
    //System.println("onEnterSleep");
    //Complications.unsubscribeFromAllUpdates();
    _lowPwrMode = true;
    _blanked = false;
    //WatchUi.requestUpdate();
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    //System.println("onExitSleep");
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