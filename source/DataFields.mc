import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time.Gregorian;
import Toybox.Complications;

class DataFields {
    var battLogEnabled = false;
    private var _currBattery;
    private var _currStress;
    private var _stressCompId;

    // https://developer.garmin.com/connect-iq/core-topics/complications/
    // https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html
    function registerComplications() {
        if (Toybox has :Complications) {
            //System.println("registering complications");
            Complications.registerComplicationChangeCallback(self.method(:onComplicationChanged));
            _stressCompId = new Complications.Id(Complications.COMPLICATION_TYPE_STRESS);
        }
    }

    function subscribeStress() {
        Complications.subscribeToUpdates(_stressCompId);
    }

    function unsubscribeStress() {
        _currStress = null;
        Complications.unsubscribeFromUpdates(_stressCompId);
    }

    function onComplicationChanged(id as Complications.Id) as Void {
        //System.println("onComplicationChanged");
        var comp = Complications.getComplication(id);

        if (id == _stressCompId) {
            //System.println("stress updated: " + comp.value);
            _currStress = comp.value;
            return;
        }
    }

    function getDate(dateInfo as Gregorian.Info) {
        return Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week, dateInfo.month, dateInfo.day]);
    }

    function getTime() {
        var time = System.getClockTime();
        return Lang.format("$1$:$2$", [time.hour.format("%02d"), time.min.format("%02d")]);
    }

    function getHeartRate() {
        var hr = Activity.getActivityInfo().currentHeartRate;
        if (hr != null && hr != 0 && hr != 255) {
            return hr;
        }
        return "--";
    }

    function getHeartRateHist() {
        var sample = ActivityMonitor.getHeartRateHistory(1, true).next();
        if (sample != null && sample.heartRate != null) {
            return "[" + sample.heartRate + "]";
        }
        return "--";
    }
    
    function getBodyBattery() {
        // https://developer.garmin.com/connect-iq/api-docs/Toybox/SensorHistory.html
        if ((Toybox has :SensorHistory) && (SensorHistory has :getBodyBatteryHistory)) {
            var history = SensorHistory.getBodyBatteryHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST });
            var sample = history.next();
            if (sample != null && sample.data != null && sample.data >= 0 && sample.data <= 100) {
                return sample.data.format("%d") + "%";
            }
        }
        return "--";
    }

    function getStress() {
        if (_currStress != null) {
            return _currStress + "%";
        }

        if ((Toybox has :SensorHistory) && (SensorHistory has :getStressHistory)) {
            //var history = SensorHistory.getStressHistory({});
            var history = SensorHistory.getStressHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST });
            var sample = history.next();
            if (sample == null) {
                return "n/a";
            }
            //if (sample != null && sample.data >= 0 && sample.data <= 100) {
            return "[" + sample.data.format("%d") + "%" + "]";
            //}
        }

        return "--";
    }

    function getSteps() {
        // https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityMonitor/Info.html
        return ActivityMonitor.getInfo().steps;
    }

    function getTemperature() {    
        if ((Toybox has :SensorHistory) && (SensorHistory has :getTemperatureHistory)) {
            var iterator = SensorHistory.getTemperatureHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST });
            var sample = iterator.next();
            if (sample != null && sample.data != null) {
                return sample.data.format("%d") + "°";
            }
        }
        return "--";
    }

    function getBattery() {
        //System.println("getBattery");
        var batt = System.getSystemStats().battery;
        if (batt != _currBattery) {
            _currBattery = batt;
            if (battLogEnabled) {
                var time = System.getClockTime();
                System.println(Lang.format("Battery,$1$:$2$:$3$,$4$", [time.hour.format("%02d"), time.min.format("%02d"), time.sec.format("%02d"), _currBattery]));
            }
        }
        return Lang.format("$1$%", [_currBattery.format("%d")]);
        //return battery.format("%.2f") + "%";
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
}
