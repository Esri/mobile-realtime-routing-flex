package controller
{
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.WebMercatorMapPoint;
	import com.esri.ags.utils.WebMercatorUtil;
	
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import flash.events.GeolocationEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.sensors.Geolocation;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import events.MasterMsgEvent;
	
	import model.GPSDataModel;
	import model.GPSLocation;

	/**
	 * This class handles writing to both the local SharedObject and the singleton GPSDataController
	 * which allows for sharing of data between views. Simply instantiating the class will start
	 * the Geolocation listener which is dependant on device and user settings.
	 */	
	public final class GeolocationController extends EventDispatcher
	{
		private var _geoLocation:Geolocation = null;
		private var _gpsDataModel:GPSDataModel;
		private var _sharedObject:SharedObject;
		private var _gpsLocation:GPSLocation;	
		private var _util:GeomUtil;
		private var _timer:Timer;
		private var _currentTime:Date;
		private var _lastUpdateTime:Date = null;
		private var _previousMapPoint:MapPoint = null;
		private const _SPEED_THRESHOLD:Number = 15; //mph
		private const _GEOLOCATION_POLLING_INTERVAL_SHORT:Number = 1000; //msecs	
		private const _GEOLOCATION_POLLING_INTERVAL_DEFAULT:Number = 5000; //msecs	
		private const _DISTANCE_ACCURACY_THRESHOLD:Number = 2500; //feet
		private const _TIME_ACCURACY_THRESHOLD:Number = 1000; //msecs
		
		/**
		 * This class handles writing to both the local SharedObject and the singleton GPSDataController
		 * which allows for sharing of data between views. Simply instantiating the class will start
	 	 * the Geolocation listener which is dependant on device and user settings.
		 */
		public function GeolocationController()
		{	
			_gpsLocation = new GPSLocation(); 						
			//_geoLocation = new Geolocation();	
			 
			//This class use a singleton to pass data back and forth between views to reduce the number of times
			//that you have to access SharedObject and improve performance.
			_gpsDataModel = GPSDataModel.getInstance();
			_gpsDataModel.addEventListener(MasterMsgEvent.GEOLOCATION_CHANGE_REQUEST,geolocationChangeRequestHandler);
			
			//Default setting for this app is Geolocation is not active (off)
			_gpsDataModel.gpsActivated = false;		
			
			_util = new GeomUtil(_gpsDataModel.map);
			
			_timer = new Timer(100,0);
			_timer.addEventListener(TimerEvent.TIMER,timerHandler);
			_timer.start();
		}
		
		private function startGeolocation(pollingInterval:Number):void
		{
			if(_geoLocation == null)
			{
				_geoLocation = new Geolocation();
				_geoLocation.setRequestedUpdateInterval(pollingInterval);
				_geoLocation.addEventListener(GeolocationEvent.UPDATE, geolocationUpdateHandler);
				_geoLocation.addEventListener(StatusEvent.STATUS, geolocationStatusChangeHandler);
				_gpsDataModel.dispatchEvent(new MasterMsgEvent(MasterMsgEvent.GEOLOCATION,true));				
			}
		}
		
		private function stopGeolocation():void
		{
			_geoLocation.removeEventListener(GeolocationEvent.UPDATE, geolocationUpdateHandler);
			_geoLocation = null;
			_timer.stop();
			_gpsDataModel.dispatchEvent(new MasterMsgEvent(MasterMsgEvent.GEOLOCATION,false));
		}
		
		/**
		 * We are using one SharedObjectChangeHandler. You could seperate all these into individual
		 * properties and different listeners. Since the needs of this app are fairly
		 * simple this works for now.
		 */
		private function geolocationChangeRequestHandler(event:MasterMsgEvent):void
		{				
			if(event.data == "start")
			{
				
				//More info: http://help.adobe.com/en_US/as3/dev/WS144092a96ffef7cc-66bf4d0212658dde8c4-7fff.html
				//Note: Check for muted because user can block application access to location.
				//Can also listen for !_geoLocation.hasEventListener(GeolocationEvent.UPDATE)
				if (Geolocation.isSupported)
				{
					_gpsDataModel.gpsActivated = true; 
					_gpsDataModel.gpsSupported = true;
					
					startGeolocation(_GEOLOCATION_POLLING_INTERVAL_DEFAULT);					
					trace("Geolocation started");					
				}
				else
				{
					trace("Geolocation not supported");
					_gpsDataModel.gpsSupported = false;
					_gpsDataModel.dispatchEvent(new MasterMsgEvent(MasterMsgEvent.GPS_SUPPORTED,false));				
				}					
			}
			
			if(event.data == "stop") 
			{
				_gpsDataModel.gpsActivated = false;
				
				if(_geoLocation != null){
					if(_geoLocation.hasEventListener(GeolocationEvent.UPDATE))
					{
						stopGeolocation();
						trace("Geolocation stopped.");
					}					
				}
				
				trace("GPS false");					
			}
			
			//Full shutdown of entire application and halt all operations.
			//Note: This will not work on iOS-based devices.
			if(event.data == "shutdown")
			{				
				_gpsDataModel.gpsActivated = false; 
				NativeApplication.nativeApplication.exit();	
			}
		}		
		
		/**
		 * As of September 2011, the heading parameter is not currently supported on Android.
		 */
		private function geolocationUpdateHandler(e:GeolocationEvent):void
		{
			trace(e.longitude + ", " + e.latitude);
			_gpsLocation.lat = String ( e.latitude );
			_gpsLocation.lon = String ( e.longitude );
			_gpsLocation.heading = e.heading;
			_gpsLocation.altitude = e.altitude;
			_gpsLocation.speed = e.speed;
			_gpsLocation.timeStamp = e.timestamp;
			_gpsLocation.horizontalAccuracy = e.horizontalAccuracy;
			_gpsLocation.verticalAccuracy = e.verticalAccuracy;
			
			//Use singleton to pass data between views
			//rather than having to access local store every time you change views	
			_gpsDataModel.GPSData = _gpsLocation;
			_gpsDataModel.currentMapPoint = new WebMercatorMapPoint(e.longitude, e.latitude);		
			
			var isValid:Boolean = locationAccuracyCheck(_gpsLocation);
			
			if(isValid == true){
				_gpsDataModel.dispatchEvent(new MasterMsgEvent(MasterMsgEvent.GPS_CHANGE,_gpsLocation));
				
				var dict:Dictionary = new Dictionary();
				dict["GPSChange"] = _gpsLocation;
				_gpsDataModel.dispatchEvent(new MasterMsgEvent(MasterMsgEvent.SHAREDOBJECT_CHANGE,dict));			
			}
			
			//Increase the polling interval if the speed goes over a certain amount.
			if(e.speed > _SPEED_THRESHOLD){
				_geoLocation.setRequestedUpdateInterval(_GEOLOCATION_POLLING_INTERVAL_DEFAULT);
			}
			else{
				_geoLocation.setRequestedUpdateInterval(_GEOLOCATION_POLLING_INTERVAL_SHORT);
			}
				
		}
			
		
		private function timerHandler(event:TimerEvent):void
		{
			_currentTime = new Date();
		}
		
		/**
		 * Minimize annoying fluctuations when accuracy is low. This is a side effect of
		 * the Geolocation API. This algorythm could use some tweaking.
		 */
		private function locationAccuracyCheck(gpsLocation:GPSLocation):Boolean
		{
			var isValid:Boolean = false;
			
			if(_lastUpdateTime != null && _previousMapPoint != null)
			{
				var pt1:MapPoint = WebMercatorUtil.webMercatorToGeographic(_previousMapPoint) as MapPoint;
				var pt2:MapPoint = WebMercatorUtil.webMercatorToGeographic(_gpsDataModel.currentMapPoint) as MapPoint;
				
				var accuracy:Number = _gpsDataModel.GPSData.horizontalAccuracy * 3.280839895; //convert meters to feet
				
				//Calculate distance between two points in miles
				var distanceSinceLastUpdate:Number = _util.degreesToMiles(
					pt1.x,pt2.x,pt1.y,pt2.y	
				);
				
				//Calculate time elapsed since last update
				var f:Number = _currentTime.time - _lastUpdateTime.time;

				//Minimize annoying fluctuations.				
				if(f >= _TIME_ACCURACY_THRESHOLD 
					&& accuracy <= _DISTANCE_ACCURACY_THRESHOLD 
					&& distanceSinceLastUpdate < _DISTANCE_ACCURACY_THRESHOLD / 5280)
				{
					isValid = true;
				}

				
			}
			else
			{
				_lastUpdateTime = _currentTime;
				isValid = true; //let first location go. NOTE: This is optional!
			}
			
			_previousMapPoint = _gpsDataModel.currentMapPoint;
			
			return isValid;
		}
		
		/**
		 * Monitor if the user or device disables or denies access to Geolocation updates.
		 */
		private function geolocationStatusChangeHandler(event:StatusEvent):void
		{
			if(_geoLocation.muted)
			{
				stopGeolocation();
			}
		}		
	}
}