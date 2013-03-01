package model
{
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.GraphicsLayer;
	
	import flash.events.EventDispatcher;
	import flash.sensors.Geolocation;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	/**
	 * Singleton class used for easily passing data between mobile views.
	 * Provides a framework for commercial applications to manage complex data.
	 */
	public class GPSDataModel extends EventDispatcher
	{						
		/**
		 * A GPSLocation Object used for storing lat and lon.
		 */
		public var GPSData:GPSLocation;
		
		/**
		 * A string containing street number, city and state (if available)
		 */
		public var streetAddress:String;
		
		/**
		 * Use this for high performance manipulation of the directions FeatureSet.
		 */
		public var directionsFeatureSetVector:Vector.<Graphic>;
		
		/**
		 * Enable/disable the display of routing directions.
		 */
		public var routeDirectionsEnabled:Boolean;
		
		/**
		 * ArcGIS map object.
		 */
		public var map:Map;
		
		/**
		 * An ArcGIS GraphicsLayer.
		 */
		public var graphicsLayer:GraphicsLayer;
		
		/**
		 * The default zoom level when the app is actively tracking on a map.
		 */
		public var defaultZoom:Number;
		
		/**
		 * Used for storing a map extent.
		 */
		public var extent:Extent;
		
		/**
		 * Indicates whether or not GPS or Geolocation service has been activated.
		 */
		public var gpsActivated:Boolean;
		
		/**
		 * Indicates whether or not the device supports or allows access to Geolocation.
		 */
		public var gpsSupported:Boolean;
		
		/**
		 * The users current location stored as a MapPoint.
		 */
		public var currentMapPoint:MapPoint;
		
		/**
		 * The current status of the phone's network connection.
		 */
		public var networkStatus:Boolean;
		
		/**
		 * Stores the map layers in an ArrayCollection.
		 */
		public var mapLayersArrayCollection:ArrayCollection;
		
		private static var _classInstance:GPSDataModel = new GPSDataModel();
		
		/**
		 * Singleton used to easily pass data across mobile views.
		 * Provides a framework for commercial applications to manage complex data.
		 */
		public function GPSDataModel()
		{
			if(_classInstance)
			{
				throw new Error("GPSDataManager can only be access through GPSDataManager.getInstance()");
			}
		}
		
		/**
		 * Get an instance of this singleton.
		 */ 
		public static function getInstance():GPSDataModel
		{
			return _classInstance;
		}
	}
}