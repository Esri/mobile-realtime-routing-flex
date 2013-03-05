package controller
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.sensors.Geolocation;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	import model.GPSDataModel;
	
	import mx.collections.ArrayCollection;
	import mx.effects.Fade;
	import mx.events.EffectEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.TitleWindow;
	import spark.effects.Scale;
	
	import views.MapView;

	[Bindable]
	public final class MapViewController
	{
		public var view:MapView;
		private var _titlewindow:TitleWindow;
		private var _gpsDataModel:GPSDataModel;			
		
		[Embed('/assets/arrow_up2.png')]
		private var _upArrowIcon:Class;	
		
		[Embed('/assets/arrow_down2.png')]
		private var _downArrowIcon:Class;		
		
		public function MapViewController()
		{
			_gpsDataModel = GPSDataModel.getInstance();	
			_titlewindow = new TitleWindow();
		}
		
		/**
		 * Returns a String determine whether or not the phone
		 * is "iphone" or "ipad".
		 */		
		public function detectiOS():String
		{
			var osString:String = Capabilities.os.toLowerCase();
			if(osString.search("iphone") != -1 && osString.search("ipad") == -1)
			{
				return "iphone";
			}				
			else if(osString.search("ipad") != -1)
			{
				return "ipad";
			}
			
			return null;				
		}			
		
		private function populateTitleWindow(title:String):void
		{			
			_titlewindow.height = 0;
			//_titlewin.width = 100;
			_titlewindow.title = title; 
			_titlewindow.id = "mapViewTitleWindow";
			_titlewindow.setStyle("modalTrasparancy",1);
			_titlewindow.setStyle("modalTransparencyBlur",100);
			_titlewindow.setStyle("modalTransparencyColor",0xf0f0f0);
			_titlewindow.setStyle("modalTransparencyDuration",1000);			
			
			//User can click/touch on _titleWindow to close it.
			_titlewindow.addEventListener(MouseEvent.CLICK,function titleWindowCloseHandler(event:MouseEvent):void{
				PopUpManager.removePopUp(_titlewindow);
			});
			
			PopUpManager.addPopUp(_titlewindow,view.parentApplication as DisplayObject ,true);
			PopUpManager.centerPopUp(_titlewindow); 
		}
		
		/**
		 * Provides a central mechanism for controlling User Interface components.
		 * It lets you encapsulate or group UI functionality into discrete scenarios.
		 * @param dict Uses Key Value pairs to provide UI instructions.
		 */
		public function UIController(dict:Dictionary):void
		{				
			if(dict["directionsBusyIndicator"] == true)
			{
				view.busyIndicator3.includeInLayout = true;
				view.busyIndicator3.visible = true;
				delete dict["directionsBusyIndicator"];
			}
			
			if(dict["directionsBusyIndicator"] == false)
			{
				view.busyIndicator3.includeInLayout = false;
				view.busyIndicator3.visible = false;
				delete dict["directionsBusyIndicator"];
			}
			
			if(dict["iOSType"] == "iphone")
			{
				//iOS does not support calling Capabilities.exit() to terminate the app
				//http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/desktop/NativeApplication.html#exit%28%29
				view.shutdownButton.visible = false;
				view.mapViewVGroup1.top = 50;					
				delete dict["iOSType"];
			}
			
			if(dict["iOSType"] == "ipad")
			{
				view.shutdownButton.visible = false;
				view.mapViewVGroup1.top = -30;					
				delete dict["iOSType"];
			}
			
			if(dict["gpsActivated"])
			{
				if(_gpsDataModel.gpsActivated == false)
				{
					view.gpsButton.label = "GPS Off";
					view.gpsVGroup.visible = false;
				}
				else
				{
					view.gpsButton.label = "GPS On";
					view.gpsVGroup.visible = true;
				}
				
				delete dict["gpsActivated"];
			}
			
			if(dict["geolocationActivated"])
			{
				if(_gpsDataModel != null)
				{
					if(_gpsDataModel.gpsActivated == true)
					{
						view.gpsVGroup.visible = true;					
					}
					else
					{					
						view.gpsVGroup.visible = false;					
					}									
				}
				else
				{
					view.gpsVGroup.visible = false;	
				}
				
				delete dict["geolocationActivated"];
			}
			
			if(dict["networkService"])
			{
				populateTitleWindow("Network connection lost.");
				
				delete dict["networkService"];
			}
			
			if(dict["gpsButtonLabel"])
			{
				if(Geolocation.isSupported == false)
				{	
					populateTitleWindow("Phone doesn't support Geolocation!");
				}	
				
				if(_gpsDataModel && _gpsDataModel.gpsActivated == true)
				{											
					view.gpsButton.label = "GPS On"; 
				}
					
				else if(_gpsDataModel && _gpsDataModel.gpsActivated == false)
				{						
					view.gpsButton.label = "GPS Off";					
				}	
				
				delete dict["gpsButtonLabel"];					
			}
			
			if(dict["routeTaskFaultPopUpWarning"])
			{
				populateTitleWindow("Not able to calculate a route!");
				delete dict["routeTaskFaultPopUpWarning"];
			}
			
			if(dict["mapSwitcherLabelBasic"])
			{
				if(view.mapSwitcher.label == "Topo")
				{
					view.mapSwitcher.label = "Streets";
					view._mapLayer = new ArrayCollection([true,false,false]);
				}
				else if(view.mapSwitcher.label == "Satellite")
				{
					view.mapSwitcher.label = "Topo";
					view._mapLayer = new ArrayCollection([false,false,true]);
				}
				else if(view.mapSwitcher.label == "Streets")
				{
					view.mapSwitcher.label = "Satellite";
					view._mapLayer = new ArrayCollection([false,true,false]);
				}	
				
				delete dict["mapSwitcherLabelBasic"];
			}
			
			if(dict["mapViewGroup1Visible"])
			{										
				var scale:Scale = new Scale(view.mapViewVGroup1);
				scale.duration = 500;

				if(view.mapViewVGroup1.scaleX == 0)
				{
					view.navButton1.setStyle("icon",this["_upArrowIcon"]);
					scale.end();
					scale.scaleXFrom = 0;
					scale.scaleXTo = 1;
					scale.scaleYFrom = 0;
					scale.scaleYTo = 1;
					scale.play();
				}
				else
				{
					view.navButton1.setStyle("icon",this["_downArrowIcon"]);
					scale.end();
					scale.scaleXFrom = 1;
					scale.scaleXTo = 0;
					scale.scaleYFrom = 1;
					scale.scaleYTo = 0;
					scale.play();
				}
				
				delete dict["mapViewGroup1Visible"];
			}
			
			if(dict["routeDirectionsContainerVisible"] && _gpsDataModel != null)
			{	
				view.routeDirectionsContainer.visible = !view.routeDirectionsContainer.visible;
				
				if(view.routeDirectionsContainer.visible)
				{
					var fade1:Fade = new Fade(view.routeDirectionsContainer);
					fade1.alphaFrom = 0.0;
					fade1.alphaTo = 1.0;
					fade1.duration = 750;
					fade1.play();						
				}
				
				if(view.routeDirectionsContainer.visible == true && _gpsDataModel.streetAddress != null)
				{
					view.fromTx.text = _gpsDataModel.streetAddress;												
				}
				
				if(view.directionsList.dataProvider != null)
				{
					view.directionsList.includeInLayout = true;
					view.directionsList.visible = true;
					
					view.directionsTextArea.includeInLayout = true;						
					view.directionsTextArea.visible = true;		
					
					view.mapViewTitleLabel.visible = false;
					view.mapViewTitleLabel.includeInLayout = false;	
				}
				else
				{
					view.directionsList.includeInLayout = false;
					view.directionsList.visible = false;	
					
					view.directionsTextArea.includeInLayout = false;
					view.directionsTextArea.visible = false;
					
					view.mapViewTitleLabel.visible = true;
					view.mapViewTitleLabel.includeInLayout = true;						
				}
				
				if(Geolocation.isSupported == false)
				{	
					populateTitleWindow("Phone doesn't support Geolocation!");
				}										
				
				delete dict["routeDirectionsContainerVisible"];					
			}	
			
			if(dict["routeDirectionsContainerVisible"] == false)
			{
				var fade2:Fade = new Fade(view.routeDirectionsContainer);
				fade2.alphaFrom = 1.0;
				fade2.alphaTo = 0.0;
				fade2.duration = 750;
				fade2.addEventListener(EffectEvent.EFFECT_END,function fadeEnd(event:EffectEvent):void{
					view.routeDirectionsContainer.visible = false;
				});
				fade2.play();		
				
				delete dict["routeDirectionsContainerVisible"];	
			}
			
			if(dict["directionsList"] == true)
			{
				if(view.directionsList.dataProvider != null)
				{						
					view.directionsList.includeInLayout = true;					
					view.directionsList.visible = true;
					
					view.directionsTextArea.includeInLayout = true;						
					view.directionsTextArea.visible = true;	
					
					view.mapViewTitleLabel.visible = false;
					view.mapViewTitleLabel.includeInLayout = false;						
				}
				else
				{
					view.directionsList.includeInLayout = false;
					view.directionsList.visible = false;		
					
					view.directionsTextArea.includeInLayout = false;
					view.directionsTextArea.visible = false;
					
					view.mapViewTitleLabel.visible = true;
					view.mapViewTitleLabel.includeInLayout = true;							
				}
				
				delete dict["directionsList"];
			}	
			
		}			
	}
}