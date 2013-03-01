package model
{
	/**
	 * Model for storing the phone's GPS data.
	 */
	public class GPSLocation
	{		
		public var lat:String;
		public var lon:String;
		public var heading:Number;
		public var altitude:Number;
		public var speed:Number;
		public var timeStamp:Number;
		public var verticalAccuracy:Number;
		public var horizontalAccuracy:Number;
		
		/**
		 * Model for storing the phone's GPS data.
		 */
		public function GPSLocation()
		{
		}
	}
}