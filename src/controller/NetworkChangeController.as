package controller
{
	import air.net.ServiceMonitor;
	import air.net.URLMonitor;
	
	import events.MasterMsgEvent;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.net.URLRequest;
	
	import model.GPSDataModel;

	/**
	 * Detect changes in network connection. Attempts to connect to a URL.
	 * Listen for changes using MasterMsgEvent.NETWORK_STATUS.
	 */
	public final class NetworkChangeController
	{
		private var _urlMonitor:URLMonitor;
		private var _gpsDataModel:GPSDataModel;
		private const _MAP_URL:String = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer";

		/**
		 * Detect changes in network connection. Set up an event listerner for the 
		 * MasterMsgEvent.NETWORK_STATUS event.
		 * @param autoStart You can have the controller start monitoring upon instantiation (true),
		 * or have the monitor start later (default) when you manually issue a start() request.
		 */		
		public function NetworkChangeController(autoStart:Boolean = false)
		{
			_gpsDataModel = GPSDataModel.getInstance();
			
			var req:URLRequest = new URLRequest(_MAP_URL);
			_urlMonitor = new URLMonitor(req); 
			_urlMonitor.addEventListener(StatusEvent.STATUS,serviceMonitorStatusHandler);
			NativeApplication.nativeApplication.addEventListener(Event.NETWORK_CHANGE,networkChangeHandler);
			if(autoStart)checkNetwork();
		}
		
		private function networkChangeHandler(event:Event):void
		{
			if(!_urlMonitor.running)
			{
				_urlMonitor.start();
			}
		}
		
		private function serviceMonitorStatusHandler(event:StatusEvent):void
		{
			trace("Network Status Event: " + event.code + ", " + _urlMonitor.available);
			_gpsDataModel.dispatchEvent(new MasterMsgEvent(MasterMsgEvent.NETWORK_STATUS,event.code));
			_urlMonitor.stop();
			
			event.code == "Service.unavailable" ? _gpsDataModel.networkStatus = false : _gpsDataModel.networkStatus = true;
		}
		
		/**
		 * This method attempts to start urlMonitor. Listen for MasterMsgEvent.NETWORK_STATUS.
		 */
		public function checkNetwork():void
		{
			if(!_urlMonitor.running)
			{
				_urlMonitor.start();
			}
		}
		
		/**
		 * Returns the map URL that is being checked.
		 */
		public function get mapUrl():String
		{
			return _MAP_URL;
		}
	}
}