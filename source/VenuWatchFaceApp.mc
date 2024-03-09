import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class VenuWatchFaceApp extends Application.AppBase {
    private var _view = null;

    function initialize() {
        System.println("app initialize");
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        System.println("app onStart");
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        System.println("app onStop");
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        System.println("getInitialView");
        _view = new VenuWatchFaceView();
        _view.loadSettings();
        return [_view, new WatchDelegate()] as Array<Views or InputDelegates>;
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        System.println("onSettingsChanged");
        if (_view != null) {
            _view.loadSettings();
            WatchUi.requestUpdate();
        }
    }
}

function getApp() as VenuWatchFaceApp {
    return Application.getApp() as VenuWatchFaceApp;
}
