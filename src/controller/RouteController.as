package controller
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.events.RouteEvent;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.tasks.Locator;
	import com.esri.ags.tasks.RouteTask;
	import com.esri.ags.tasks.supportClasses.AddressCandidate;
	import com.esri.ags.tasks.supportClasses.AddressToLocationsParameters;
	import com.esri.ags.tasks.supportClasses.DirectionsFeatureSet;
	import com.esri.ags.tasks.supportClasses.RouteParameters;
	import com.esri.ags.tasks.supportClasses.RouteResult;
	
	import events.MasterMsgEvent;
	
	import flash.events.EventDispatcher;
	
	import model.GPSDataModel;
	
	import mx.rpc.AsyncResponder;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	
	import spark.effects.easing.Sine;

	/**
	 * Class for creating routes using an ArcGIS Locator Service.
	 */
	public class RouteController extends EventDispatcher
	{
		[Bindable]private var stopsFS:FeatureSet = new FeatureSet();
		
		[Bindable]private var directionsFS:DirectionsFeatureSet;
		
		private var _locator:Locator;
		private var _toText:String;
		private var _fromText:String;
		private var _graphicsLayer:GraphicsLayer;
		private var _toSymbol:SimpleMarkerSymbol;
		private var _fromSymbol:SimpleMarkerSymbol;
		private var _routeSymbol:SimpleLineSymbol;
		private var _gpsDataController:GPSDataModel;
		private var _routeTask:RouteTask;
		private var _routeParams:RouteParameters;
		[Bindable]private var _map:Map;
				
		[Bindable]
		[Embed('/assets/marker_start_large.png')]
		private var _routeStartMarkerClass:Class;
		private var _routeStartMarkerSymbol:PictureMarkerSymbol;
		private var _routeStartMarkerGraphic:Graphic;

		[Bindable]
		[Embed('/assets/marker_end_large.png')] 
		private var _routeEndMarkerClass:Class;
		private var _routeEndMarkerSymbol:PictureMarkerSymbol;
		private var _routeEndMarkerGraphic:Graphic;		
		
		/**
		 * Class for creating routes using an ArcGIS Locator Service.
		 * @param map The map object for the application.
		 * @param toText Where you are navigating to.
		 * @param fromText Where you are starting out.
		 * @param graphicsLayer GraphicsLayer on which to draw the route info.
		 * @param clearLayer Indicates if you want to clear the layer every time you launch a route task.
		 */		
		public function RouteController(map:Map,toText:String,fromText:String,graphicsLayer:GraphicsLayer,clearLayer:Boolean = false)
		{
			_map = map;	
			_toText = toText;
			_fromText = fromText;
			_graphicsLayer = graphicsLayer;
			if(clearLayer)_graphicsLayer.clear();
			_gpsDataController = GPSDataModel.getInstance();
			
			//_toSymbol = new SimpleMarkerSymbol("circle",30,0xFF0000);
			_routeEndMarkerSymbol = new PictureMarkerSymbol(_routeEndMarkerClass);
			//_fromSymbol = new SimpleMarkerSymbol("circle",30,0x00FF00);
			_routeStartMarkerSymbol = new PictureMarkerSymbol(_routeStartMarkerClass);
			_routeSymbol = new SimpleLineSymbol("solid",0x0000FF,0.5,8);
			
			_routeTask = new RouteTask("http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route");
			_routeTask.concurrency = "last";
			_routeTask.requestTimeout = 30; //30 secs
			_routeTask.showBusyCursor = true;
			_routeTask.addEventListener(FaultEvent.FAULT,routeTaskFaultHandler);
			_routeTask.addEventListener(RouteEvent.SOLVE_COMPLETE,solveCompleteHandler);
			
			_routeParams = new RouteParameters();
			_routeParams.outputGeometryPrecision = 10;
			_routeParams.directionsLengthUnits = "esriMiles";
			_routeParams.outSpatialReference = map.spatialReference;
			_routeParams.returnDirections = true;
			_routeParams.returnRoutes = false;
			_routeParams.stops = stopsFS;			
			
			_locator = new Locator("http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/TA_Address_NA_10/GeocodeServer");
			_locator.outSpatialReference = _map.spatialReference; 
			getDirections();
		}
		
		private function getDirections():void
		{
			stopsFS.features = [];
			directionsFS = null;
			
			var fromAddressParms:AddressToLocationsParameters = new AddressToLocationsParameters();
			fromAddressParms.address = { SingleLine: _fromText};
			fromAddressParms.outFields = [ "Loc_name" ];
			
			_locator.addressToLocations(fromAddressParms, new AsyncResponder(
				myResultFunction, myFaultFunction, "From"));
			
			
			var toAddressParms:AddressToLocationsParameters = new AddressToLocationsParameters();
			toAddressParms.address = { SingleLine: _toText};
			toAddressParms.outFields = [ "Loc_name" ];
			
			_locator.addressToLocations(toAddressParms, new AsyncResponder(
				myResultFunction, myFaultFunction, "To"));
			
			function myResultFunction(result:Array, token:String = null):void
			{
				solveRoute(result, token);
			}
			function myFaultFunction(error:Fault, token:Object = null):void
			{
				trace(error.faultString, "Locator Error");
				_gpsDataController.dispatchEvent(new MasterMsgEvent(MasterMsgEvent.ROUTETASK_FAULT,error.faultString));
			}
		}	
		
		private function solveRoute(addressCandidates:Array, type:String):void
		{
			if (addressCandidates.length == 0)
			{
				trace(type + " address not found.", "There are no result candidates.");
				_gpsDataController.dispatchEvent(new MasterMsgEvent(MasterMsgEvent.ROUTETASK_FAULT,"No address result candidates found."));
				return;
			}
			
			var stop:AddressCandidate = addressCandidates[0];
			
			if (type == "From")
			{
				var fromGraphic:Graphic = new Graphic(
					stop.location, 
					_routeStartMarkerSymbol, 
					{ address: stop.address, score: stop.score,type:'from' }
				);
				_graphicsLayer.add(fromGraphic);
				stopsFS.features[0] = fromGraphic;
			}
			else if (type == "To")
			{
				var toGraphic:Graphic = new Graphic(stop.location, _routeEndMarkerSymbol, { address: stop.address, score: stop.score });
				_graphicsLayer.add(toGraphic);
				stopsFS.features[1] = toGraphic;
			}
			
			if (stopsFS.features[0] && stopsFS.features[1])
			{
				_routeTask.solve(_routeParams);
			}
		}	
		
		private function solveCompleteHandler(event:RouteEvent):void
		{
			var routeResult:RouteResult = event.routeSolveResult.routeResults[0];
			directionsFS = routeResult.directions;
			
			//var routeGr:Graphic = new Graphic(directionsFS.mergedGeometry, _routeSymbol);
			
			for each(var routeGr:Graphic in directionsFS.features)
			{			
				routeGr.symbol = _routeSymbol;
				_graphicsLayer.add(routeGr);
			}
			
			//_graphicsLayer.add(routeGr);			
			//_map.extent = routeGr.geometry.extent;
			_map.extent = directionsFS.mergedGeometry.extent; 
			_map.level = _map.level - 1;
			_gpsDataController.dispatchEvent(new MasterMsgEvent(MasterMsgEvent.ROUTETASK_COMPLETED,directionsFS));	
		}
		
		private function routeTaskFaultHandler(event:FaultEvent):void
		{
			trace("routeTaskFaultHandler: " + event.fault.faultString);
			_gpsDataController.dispatchEvent(new MasterMsgEvent(MasterMsgEvent.ROUTETASK_FAULT,event.fault.faultString));
		}
		
	}
}