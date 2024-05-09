import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class VenuWatchFaceView extends WatchUi.WatchFace {  
  private var _devSize;
  private var _devCenter;
  private var _timeFont;
  //private var _blanked = false;
  private var _lowPwrMode;
  private var _settings;
  private var _dataFields;
  private const _toRads = Math.PI / 180;
  
  function initialize() {
    System.println("view initialize");
    WatchFace.initialize();
    
    _settings = new Settings();
    loadSettings();
    
    _dataFields = new DataFields();
    _dataFields.registerComplications();
    _dataFields.battLogEnabled = _settings.battLogEnabled;

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
    System.println("onShow");
    //_settings.loadSettings();
    _lowPwrMode = false;
    _dataFields.subscribeStress();
  }

  // Updates the view.
  // Called every second in high power mode.
  // Called once a minute in low power mode.
  function onUpdate(dc as Dc) as Void {
    //System.print("onUpdate: ");

    if (_lowPwrMode) {
      //System.println("low power mode");
      //drawScreenSaver(dc);
      if (_settings.battLogEnabled) {
        _dataFields.getBattery();
      }
      return;
    }

    //System.println("drawing");
    clearScreen(dc);

    // lines for positioning
    if (_settings.showGrid) {
      drawGrid(dc);
    }

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

    // time
    drawHour(dc, dateInfo);
    drawMinutes(dc, dateInfo);
    drawSeconds(dc, dateInfo.sec);

    // data fields
    drawDate(dc, dateInfo);
    drawHR(dc);
    drawConnectionStatus(dc);
    drawBodyBattery(dc);
    drawSteps(dc);    
    drawBattery(dc);

    //drawBoxes(dc); // for debugging bounding boxes
  }

  (:debug)
  private function clearScreen(dc as Dc) {
    dc.setColor(0, _settings.bgColor);
    dc.clear();
  }

  (:release)
  private function clearScreen(dc as Dc) {
    // no need for this on actual device
  }

  function drawDate(dc, dateInfo as Gregorian.Info) {
    dc.setColor(_settings.dateColor, -1);

    if (_settings.digitalEnabled) {
      dc.drawText(212, 52, Graphics.FONT_TINY, _dataFields.getDate(dateInfo), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    } else {
      dc.drawText(212, 80, Graphics.FONT_TINY, _dataFields.getDate(dateInfo), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
  }

  function drawHR(dc) {
    dc.setColor(_settings.hrColor, -1);

    if (_settings.digitalEnabled) {
      dc.drawText(_devCenter, 108, Graphics.FONT_TINY, _dataFields.getHeartRate(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);  
    } else {      
      dc.drawText(_devCenter, 135, Graphics.FONT_TINY, _dataFields.getHeartRate(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
  }

  function drawConnectionStatus(dc) {
    dc.setColor(_settings.connectColor, -1);
    var cs = System.getDeviceSettings().phoneConnected ? "B" : "";

    if (_settings.digitalEnabled) {
      dc.drawText(30, _devCenter, Graphics.FONT_TINY, cs, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    } else {
      dc.drawText(50, _devCenter, Graphics.FONT_TINY, cs, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
  }

  function drawHour(dc, dateInfo as Gregorian.Info) {
    dc.setColor(_settings.hourColor, -1);
    
    if (_settings.digitalEnabled) {
      dc.drawText(200, 206, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
      return;
    }
    
    // each hour is 30° + 0.5° per minute
    var angle = (dateInfo.hour * 30 + dateInfo.min * 0.5 + 270) * _toRads; 
    var x = Math.cos(angle) * 100; // radius
    var y = Math.sin(angle) * 100; // radius
    
    dc.setPenWidth(4);
    dc.drawLine(_devCenter, _devCenter, x + _devCenter, y + _devCenter);
  }

  function drawMinutes(dc, dateInfo as Gregorian.Info) {
    dc.setColor(_settings.minuteColor, -1);

    if (_settings.digitalEnabled) {
      dc.drawText(216, 206, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
      return;
    }
    
    // the minute hand moves six degrees per minute, e.g. 15 min should be 90°, 16 min should be 96°, so 15 min 30s should be 93°
    var angle = (dateInfo.min * 6 + dateInfo.sec * 0.1 + 270) * _toRads; // smoother motion
    //var angle = ((dateInfo.min + dateInfo.sec / 60.0) * 6 + 270) * _toRads; // smoother motion
    var x = Math.cos(angle) * 140; // radius
    var y = Math.sin(angle) * 140; // radius

    dc.setPenWidth(2);
    dc.drawLine(_devCenter, _devCenter, x + _devCenter, y + _devCenter);
  }

  function drawSeconds(dc, sec as Number) {
    dc.setColor(_settings.secColor, -1);

    if (_settings.digitalEnabled) {
      dc.drawText(374, 148, Graphics.FONT_TINY, sec.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
      return;
    }
      
    var angle = (sec * 6 + 270) * _toRads;
    var x = Math.cos(angle) * 170; // radius
    var y = Math.sin(angle) * 170; // radius

    dc.setPenWidth(2);
    dc.drawLine(_devCenter, _devCenter, x + _devCenter, y + _devCenter);

    var s = 0;
    do {
      drawSecMarker(dc, s, 196);
      s += 1;
    } while (s < 60);

    dc.setColor(0, 0);
    dc.fillCircle(_devCenter, _devCenter, 5);

    dc.setColor(0xFF0000, 0);
    dc.drawCircle(_devCenter, _devCenter, 5);
  }

  function drawBodyBattery(dc) {
    dc.setColor(_settings.bodyBattColor, -1);

    if(_settings.digitalEnabled) {
      dc.drawText(156, 312, Graphics.FONT_TINY, _dataFields.getBodyBattery(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    } else {
      dc.drawText(156, 290, Graphics.FONT_TINY, _dataFields.getBodyBattery(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
  }

  function drawSteps(dc) {
    dc.setColor(_settings.stepsColor, -1);

    if (_settings.digitalEnabled) {
      dc.drawText(260, 312, Graphics.FONT_TINY, _dataFields.getSteps(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    } else {
      dc.drawText(260, 290, Graphics.FONT_TINY, _dataFields.getSteps(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
  }

  function drawBattery(dc) {
    dc.setColor(_settings.battColor, -1);

    if (_settings.digitalEnabled) {
      dc.drawText(_devCenter, 376, Graphics.FONT_TINY, _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    } else {
      dc.drawText(_devCenter, 350, Graphics.FONT_TINY, _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
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

  // for AOD display
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

  private function drawSecDot(dc, sec, radius) {
    dc.setColor(_settings.secColor, -1);

    // similar to analog sdk sample
    //var angle = (sec / 60.0) * Math.PI * 2;
    //var x = Math.sin(angle) * radius + 0.5;
    //var y = Math.cos(angle) * -radius;

    // from https://github.com/bombsimon/garmin-seaside
    //var angle = Math.toRadians((sec * 6 + 270));
    var angle = (sec * 6 + 270) * _toRads;
    var x = Math.cos(angle) * radius;
    var y = Math.sin(angle) * radius;

    dc.fillCircle(x + _devCenter, y + _devCenter, 8);
    //dc.drawLine(_devCenter, _devCenter, x + _devCenter, y + _devCenter);
  }
  
  private function drawSecMarker(dc, sec, radius) {
    dc.setColor(Graphics.COLOR_DK_GRAY, -1);
    var len = sec % 5 == 0 ? 20 : 10;
    var angle = (sec * 6 + 270) * _toRads;
    var x1 = Math.cos(angle) * (radius - len);
    var y1 = Math.sin(angle) * (radius - len);
    var x2 = Math.cos(angle) * radius;
    var y2 = Math.sin(angle) * radius;
    dc.drawLine(x1 + _devCenter, y1 + _devCenter, x2 + _devCenter, y2 + _devCenter);
  }

  function drawBoxes(dc) {
    var width = dc.getWidth();
    var devCenter = width / 2;
    dc.setColor(Graphics.COLOR_ORANGE, -1);

    // df 01
    dc.drawRectangle(devCenter - 26, 90, 52, 40);

    //
    dc.drawRectangle(70, 294, 70, 40);
  }

  // Called when this View is removed from the screen. Save the state of this View here.
  // This includes freeing resources from memory.
  function onHide() as Void {
    System.println("onHide");
    _lowPwrMode = true;
    _dataFields.unsubscribeStress();
  }

  // Terminate any active timers and prepare for slow updates (once a minute).
  function onEnterSleep() as Void {
    System.println("onEnterSleep");
    _lowPwrMode = true;
    _dataFields.unsubscribeStress();
    //_blanked = false;
    //WatchUi.requestUpdate();
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    System.println("onExitSleep");
    _lowPwrMode = false;
    _dataFields.subscribeStress();
    //WatchUi.requestUpdate();
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