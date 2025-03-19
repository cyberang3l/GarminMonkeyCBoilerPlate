import Toybox.Lang;
using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;

class Background extends WatchUi.Drawable {

  function initialize() {
    var dictionary = {
      :identifier => "Background"
    };

    Drawable.initialize(dictionary);
  }

  function draw(dc as Graphics.Dc) {
    // Set the background color then call to clear the screen
    dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
    dc.clear();
  }

}

class BoilerplateAppView extends WatchUi.WatchFace {

  hidden var fgColor = Graphics.COLOR_WHITE;
  hidden var timeFormat;
  hidden var hoursFormat;
  hidden var timeLabel;

  function initialize() {
    WatchFace.initialize();
  }

  // Set the callFromOnLayout to true only when calling this function from the
  // "onLayout" function and we know we just load the watch face, as we need to
  // setup a few more things in this case.
  function configAppSettings(callFromOnLayout as Boolean) {
    timeLabel = View.findDrawableById("TimeLabel") as WatchUi.Text;
    timeLabel.setColor(fgColor);

    if (Application.Properties.getValue("UseMilitaryFormat")) {
      timeFormat = "$1$$2$";
      hoursFormat = "%02d";
    } else {
      timeFormat = "$1$:$2$" as String;
      hoursFormat = "%d" as String;
    }
  }

  function onLayout(dc as Graphics.Dc) {
    setLayout(Rez.Layouts.WatchFace(dc));

    configAppSettings(true);
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() {
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {
  }

  function drawTime() {
    var devSettings = System.getDeviceSettings();
    var time = System.getClockTime();
    var hours = time.hour;
    if (!devSettings.is24Hour) {
      if (hours > 12) {
        hours = hours - 12;
      }
    }
    var timeString = format(timeFormat, [hours.format(hoursFormat), time.min.format("%02d")]);
    timeLabel.setText(timeString);
  }

  function onUpdate(dc as Graphics.Dc) {
    drawTime();

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);
  }

}

class BoilerplateApp extends Application.AppBase {

  hidden var _mainView;

  function initialize() {
    AppBase.initialize();
  }

  function getInitialView() {
    _mainView = new BoilerplateAppView();
    return [ _mainView ];
  }

  function onSettingsChanged() {
    _mainView.configAppSettings(false);
    WatchUi.requestUpdate();
  }

}
