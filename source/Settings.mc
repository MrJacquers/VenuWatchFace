import Toybox.Lang;
import Toybox.Application.Storage;

class Settings {
    // TODO: list of possible settings.

    function getValue(name, defaultValue) {
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
