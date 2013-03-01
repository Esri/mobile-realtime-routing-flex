package controller
{
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.tasks.supportClasses.DirectionsFeatureSet;
	import com.esri.ags.utils.WebMercatorUtil;
	
	import flash.system.Capabilities;
	
	/**
	 * Provides misc functionality.
	 */	
	public final class GeomUtil
	{
		private var _map:Map;
		
		/**
		 * Provides misc functionality.
		 */
		public function GeomUtil(map:Map)
		{
			_map = map;
		}
		
		/**
		 * Make sure the zoom level works for the LODs of the map
		 * between 0 and 19. For this function zero is closest to the ground
		 * and the smallest scale.
		 */
		public function setZoomLevel(level:Number):Number
		{				
			
			var arr:Array;	
			var numberofLODS:Number;
			var finalLevel:Number;
			
			if(_map && _map.lods == null)
			{
				return 10; //just return something here so you don't get a null object error
			}
			else
			{
				arr = _map.lods;
				numberofLODS = _map.lods.length;
			}
			
			finalLevel = numberofLODS - level;
			
			//If user asks for a level greater than what's available
			//for that layer...just zoom them out all the way.
			if(arr != null && finalLevel > arr.length)
			{
				return Number(arr.length);
			}
				
			//If user asks for a level that's negative
			//then zoom them in all the way.
			else if(arr != null && finalLevel < 0)
			{
				return 0;
			}
			
			return finalLevel;
		}			
		
		/**
		 * Convert degrees to miles | this function is courtesy of Gregory Gunther
		 * @param x2 Latitude of first point.
		 * @param x2 Latitude of second point.
		 * @param y1 Longitude of first point.
		 * @param y2 Longitude of second point.
		 */
		public function degreesToMiles(x1:Number, x2:Number, y1:Number, y2:Number):Number 
		{				
			//Convert Everything to radians
			var x1Radians:Number = x1 * Math.PI/180;
			var x2Radians:Number = x2 * Math.PI/180;
			var y1Radians:Number = y1 * Math.PI/180
			var y2Radians:Number = y2 * Math.PI/180
			return 3963.0 * Math.acos(
				Math.sin(y1Radians) *  
				Math.sin(y2Radians) + 
				Math.cos(y1Radians) * 
				Math.cos(y2Radians) * 
				Math.cos(x2Radians - x1Radians)
			);	
		}	
		
		/**
		 * For routing only. Provided a MapPoint and DirectionsFeatureSet this method returns the route segment number that is closest.
		 * Distance is calculated in miles via a degrees to miles conversion.
		 * @param currentLocation Any MapPoint that represents a location whether by map click or programmatically.
		 * @param directionsFS A Vector based on a DirectionsFeatureSet for the route. Use Vectors for high-performance access of the
		 * FeatureSet data. Millisecond access times and CPU usage count for alot on mobile devices.
		 */
		public function calculateClosestRouteSegment(currentLocation:MapPoint,directionsFSVector:Vector.<Graphic>):Number
		{
			var vector1:Vector.<Number> = new Vector.<Number>;
			var vector2:Vector.<Number> = new Vector.<Number>;
			var pt:MapPoint = WebMercatorUtil.webMercatorToGeographic(currentLocation) as MapPoint;
			
			//The graphics in the featureset need to be polylines
			for each(var graphic:Graphic in directionsFSVector)
			{
				var geometry:Geometry = WebMercatorUtil.webMercatorToGeographic(graphic.geometry);
				if(geometry.type == "esriGeometryPolyline")
				{					
					//convert radius in degrees to miles
					const rm : Number = degreesToMiles(
						pt.x, 
						geometry.extent.center.x, 
						pt.y, 
						geometry.extent.center.y
					);					
					
					vector1.push(rm);
					vector2.push(rm);
				}
			}
			
			vector1.sort(Array.NUMERIC); //sort so that closest segment is at vector1[0]
			 
			return vector2.indexOf(vector1[0]);
		}
				
		
		/**
		 * Used to format the distance returned in a route FeatureSet.
		 */
		public function formatDistance(dist:Number, units:String):String
		{
			var result:String = "";
			
			var d:Number = Math.round(dist * 100) / 100;
			
			if (d != 0)
			{
				result = d + " " + units;
			}
			
			return result;
		}
		
		/**
		 * Used to format the time stamp in a route FeatureSet.
		 */
		public function formatTime(time:Number):String
		{
			var result:String;
			
			var hr:Number = Math.floor(time / 60);
			var min:Number = Math.round(time % 60);
			
			if (hr < 1 && min < 1)
			{
				result = "";
			}
			else if (hr < 1 && min < 2)
			{
				result = min + " minute";
			}
			else if (hr < 1)
			{
				result = min + " minutes";
			}
			else
			{
				result = hr + " hour(s) " + min + " minute(s)";
			}
			
			return result;
		}	
			
	}
}