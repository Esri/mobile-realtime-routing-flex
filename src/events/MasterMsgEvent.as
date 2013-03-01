package events
{
	import flash.events.Event;

	/**
	 * Use as the event bus for all custom message handling in this application.
	 */
	public class MasterMsgEvent extends Event
	{
		
		/**
		 * Use this property when the phones Geolocation updates.
		 */
		public static const GPS_CHANGE:String = "GPS Change Event";
		
		/**
		 * Indicates a change in the phones network connectivity.
		 */
		public static const NETWORK_STATUS:String = "Network status change";
		
		/**
		 * Indicates a request to clear the route graphics and associated data.
		 */
		public static const ROUTE_DIRECTIONS_ENABLED:String = "Clear the route and associated data";
		
		/**
		 * Indicates that a route task has completed.
		 */
		public static const ROUTETASK_COMPLETED:String = "Route Task Completed";
		
		/**
		 * User has clicked on a textual route segment.
		 */
		public static const ROUTETEXTSEGMENT_CLICK:String = "Route Segment Click";
		
		/**
		 * Indicates there was a problem with the route task.
		 */
		public static const ROUTETASK_FAULT:String = "Route Task Fault";
		
		/**
		 * Use this property to determine whether or not GPS and/or Geolocation is supported on the device.
		 */
		public static const GPS_SUPPORTED:String = "GPS and/or Geolocation is or is/not supported.";
		
		/**
		 * Use this property to pass changes related to the local SharedObject.
		 */
		public static const SHAREDOBJECT_CHANGE:String = "SharedObject Change Event";
		
		/**
		 * Indicates that tracking has been activated/deactivated (true/false).
		 */
		public static const GEOLOCATION:String = "Tracking has been activated/deactivated.";
		
		/**
		 * Indicates that the application has issued a change to the Geolocation property.
		 */
		public static const GEOLOCATION_CHANGE_REQUEST:String = "Application is requesting a change to the Geolocation settings."; 
		
		/**
		 * Indicates that the local SharedOjbect has been deleted.
		 */
		public static const SHAREDOBJECT_DELETED:String = "SharedObject has been deleted";
		
		/**
		 * This Event class provides access to all events.
		 * @param type The type of Error.
		 * @param data The data you with to send/receive. Takes types Object, String, Array.
		 * 
		 */		
		public function MasterMsgEvent(type:*,data:*)
		{
			this.data = data;
			super(type);  			
		}
		
		/**
		 * Data that you want to send/receive. Takes types Object, String, Array.
		 */
		public var data:* = "";		
		
		public override function clone():Event
		{
			return new MasterMsgEvent(type,data);
		}	
	}
}