import Toybox.Lang;
import Toybox.Application.Storage;

class Settings {
    var bgColor;
    var dateColor;
    var hrColor; // TODO: hr zone colors
    var connectColor;
    var hourColor;
    var minuteColor;
    var secColor;
    var bodyBattColor;
    var stressColor;
    var stepsColor;
    var caloriesColor;
    var battColor; // TODO: battery % colors

    var showGrid = false;
    var digitalEnabled = false;
    var appAODEnabled = false;
    var battLogEnabled = false;

    function loadSettings() {
        // https://developer.garmin.com/connect-iq/core-topics/properties-and-app-settings/
        // Set via ConnectIQ App.
        if (Toybox.Application has :Properties) {
            bgColor = Application.Properties.getValue("BGColor").toNumberWithBase(16);
            dateColor = Application.Properties.getValue("DateColor").toNumberWithBase(16);
            hrColor = Application.Properties.getValue("HRColor").toNumberWithBase(16);
            connectColor = Application.Properties.getValue("ConnectColor").toNumberWithBase(16);            
            hourColor = Application.Properties.getValue("HourColor").toNumberWithBase(16);
            minuteColor = Application.Properties.getValue("MinuteColor").toNumberWithBase(16);
            secColor = Application.Properties.getValue("SecColor").toNumberWithBase(16);
            bodyBattColor = Application.Properties.getValue("BodyBattColor").toNumberWithBase(16);
            stressColor = Application.Properties.getValue("StressColor").toNumberWithBase(16);
            stepsColor = Application.Properties.getValue("StepsColor").toNumberWithBase(16);
            caloriesColor = Application.Properties.getValue("CaloriesColor").toNumberWithBase(16);
            battColor = Application.Properties.getValue("BattColor").toNumberWithBase(16);
        }

        // On-device settings, accessible via select watch face edit menu.
        if (Toybox.Application has :Storage) {
            showGrid = getValue("GridEnabled", false);
            digitalEnabled = getValue("DigitalEnabled", true);
            appAODEnabled = getValue("AODModeEnabled", false);
            battLogEnabled = getValue("BattLogEnabled", false);
        }
    }

    private function getValue(name, defaultValue) {
        var setting = Storage.getValue(name);
        if (setting != null) {
            return setting;
        } else {
            return defaultValue;
        }
    }

    function setValue(key, value) {
        Storage.setValue(key, value);
    }
}
