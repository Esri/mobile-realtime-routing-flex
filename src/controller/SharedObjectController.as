package controller
{
	import com.esri.ags.geometry.Extent;
	
	import events.MasterMsgEvent;
	
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	import flash.utils.getQualifiedClassName;

	import model.GPSDataModel;

	/**
	 * Used to handle application state. You could also use persistenceManager if you want.
	 * For this application I chose not to.
	 */
	public final class SharedObjectController extends EventDispatcher
	{
		private var _gpsDataModel:GPSDataModel;
		private var _sharedObject:SharedObject;
		private var _previousExtent:Extent;		
		
		/**
		 * Used to handle application state. You could also use persistenceManager if you want.
		 * For this application I chose not to.
		 */		
		public function SharedObjectController()
		{
			_sharedObject = SharedObject.getLocal("MobileMap");		
			_previousExtent = _sharedObject.data.extent;
			
			_gpsDataModel = GPSDataModel.getInstance();
			_gpsDataModel.addEventListener(MasterMsgEvent.SHAREDOBJECT_CHANGE,sharedObjectChangeHandler);			
		}
		
		private function sharedObjectChangeHandler(event:MasterMsgEvent):void
		{
			var className:String = flash.utils.getQualifiedClassName( event.data );
			
			if(className == "flash.utils::Dictionary")
			{
				for (var key:Object in event.data) 
				{
					if(key == "address")
					{
						trace("Shared Object Address Update: " + event.data.address);
						_gpsDataModel.streetAddress = event.data.address;
					}
					
					if(key == "extent")
					{
						if(_previousExtent != event.data.extent)
						{
							_sharedObject.data.extent = event.data.extent;
							_sharedObject.flush();
							_gpsDataModel.extent = event.data.extent;						
							trace("Shared Object Extent Change: " + _gpsDataModel.extent.center);
						}								
					}
					
					if(key == "mapLayer")
					{
						_gpsDataModel.mapLayersArrayCollection = event.data.mapLayer;
						_sharedObject.data.mapLayersArrayCollection = event.data.mapLayer;
						_sharedObject.flush();	
						trace("Shared Object Map Layer Change");
					}
					
					//Delete the SharedObject contents
					if(key == "Delete")
					{
						_sharedObject.clear();
						_gpsDataModel.dispatchEvent(new MasterMsgEvent(MasterMsgEvent.SHAREDOBJECT_DELETED,true));
					}
					
					if(key == "GPSChange")
					{
						_sharedObject.data.gpsLocation = event.data.GPSChange;
						_sharedObject.flush();
						
					}
				} 
			}
		}
	}
}