import Toybox.Lang;
import Toybox.Time.Gregorian;
//import Toybox.Complications;

class DataFields {
    // if using complication to get hr
    //var _hrId;
    //var _curHr;

    // https://developer.garmin.com/connect-iq/core-topics/complications/
    // https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html
    /*if (Toybox has :Complications) {
        Complications.registerComplicationChangeCallback(self.method(:onComplicationChanged));
        _hrId = new Id(Complications.COMPLICATION_TYPE_HEART_RATE);
    }*/

    /*function onComplicationChanged(id as Complications.Id) as Void {
        //System.println("onComplicationChanged");
        if (id.equals(_hrId)) {
            _curHr = Complications.getComplication(id).value;
            //System.println(_curHr);
        }
    }*/

    function getDate(dateInfo as Gregorian.Info) {
        return Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week, dateInfo.month, dateInfo.day]);
    }

    function getTime(dateInfo as Gregorian.Info) {
        return Lang.format("$1$:$2$", [dateInfo.hour.format("%02d"), dateInfo.min.format("%02d")]);
        //var clockTime = System.getClockTime();
        //return Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
    }

    function getHeartRateAI() {
        var hr = Activity.getActivityInfo().currentHeartRate;
        if (hr != null && hr != 0 && hr != 255) {
            return hr;
        }
        return "--";
    }

    /*function getHeartRateComp() {
        if (_hrId != null && _curHr != null) {
            //System.println("hr from complication");
            return;
        }
        _curHr = "--";
    }*/

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
        if ((Toybox has :SensorHistory) && (SensorHistory has :getStressHistory)) {
            var history  = SensorHistory.getStressHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST });
            var sample = history.next();
            if (sample != null && sample.data != null && sample.data >= 0 && sample.data <= 100) {
                return sample.data.format("%d") + "%";
            }
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
        return Lang.format("$1$%", [System.getSystemStats().battery.format("%d")]);
        //return battery.format("%.2f") + "%";
    }
}
