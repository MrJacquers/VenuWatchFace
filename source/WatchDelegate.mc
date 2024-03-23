import Toybox.WatchUi;
import Toybox.Complications;

class WatchDelegate extends WatchFaceDelegate {

	function initialize() {
		WatchFaceDelegate.initialize();
	}

  public function onPress(clickEvent) {
    var coords = clickEvent.getCoordinates();
    var x = coords[0];
    var y = coords[1]; 
    //System.println("onPress x:" + x + ",y:" + y);
    
    /*
    // todo: bounding boxes

    //dc.drawRectangle(118, 20, 182, 50);
    if (x >= 118 && y >= 20 && x <= 300 && y <= 70) {
      //System.println("launching date complication");
      var compId = new Complications.Id(Complications.COMPLICATION_TYPE_DATE);
      //System.println(compId);
      Complications.exitTo(compId);
      return true;
    }

    //dc.drawRectangle(182, 82, 50, 50);
    if (x >= 182 && y >= 82 && x <= 232 && y <= 132) {
      //System.println("launching hr complication");
      var compId = new Complications.Id(Complications.COMPLICATION_TYPE_HEART_RATE);
      Complications.exitTo(compId);
      return true;
    }

    //dc.drawRectangle(70, 290, 70, 50);
    if (x >= 70 && y >= 290 && x <= 140 && y <= 340) {
      //System.println("launching body battery complication");
      var compId = new Complications.Id(Complications.COMPLICATION_TYPE_BODY_BATTERY);
      Complications.exitTo(compId);
      return true;
    }

    //dc.drawRectangle(175, 290, 70, 50);
    if (x >= 175 && y >= 290 && x <= 245 && y <= 340) {
      //System.println("launching steps complication");
      var compId = new Complications.Id(Complications.COMPLICATION_TYPE_STEPS);
      Complications.exitTo(compId);
      return true;
    }

    //dc.drawRectangle(280, 290, 70, 50);
    if (x >= 280 && y >= 290 && x <= 350 && y <= 340) {
      //System.println("launching temperature complication");
      var compId = new Complications.Id(Complications.COMPLICATION_TYPE_CURRENT_TEMPERATURE);
      Complications.exitTo(compId);
      return true;
    }

    //dc.drawRectangle(170, 362, 75, 50);
    if (x >= 170 && y >= 362 && x <= 245 && y <= 412) {
      //System.println("launching battery complication");
      var compId = new Complications.Id(Complications.COMPLICATION_TYPE_BATTERY);
      Complications.exitTo(compId);
      return true;
    }
    
    */
    return false;
  }
}
