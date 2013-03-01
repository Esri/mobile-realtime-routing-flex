package controller
{
	import com.esri.ags.events.LocatorEvent;
	import com.esri.ags.tasks.Locator;
	import com.esri.ags.tasks.supportClasses.AddressCandidate;
	
	import events.MasterMsgEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StageOrientationEvent;
	import flash.utils.Dictionary;
	
	import model.GPSDataModel;
	
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	
	import spark.components.TitleWindow;
	import spark.components.View;
	import spark.effects.Resize;
	
	import views.SettingsView;

	[Bindable]
	public class SettingsViewController
	{
		public var view:SettingsView;
		private var _gpsDataModel:GPSDataModel;	
		private var _titlewindow:TitleWindow;		
		private var _resizeEffect1:Resize;
		private var _resizeEffect2:Resize;												
		
		public function SettingsViewController()
		{
			_gpsDataModel = GPSDataModel.getInstance();	
			_titlewindow = new TitleWindow();
		}
		
		private function populateTitleWindow(title:String):void
		{			
			_titlewindow.height = 0;
			//_titlewin.width = 100;
			_titlewindow.title = title; 
			_titlewindow.id = "settingsViewTitleWindow";
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
			if(dict["startViewSettings"])
			{
				view.addressTextArea.height = 0;
				view.GPSTextArea.height = 0;
				view.addressTextArea.visible = false;
				view.addressTextArea.includeInLayout = false;
				view.GPSTextArea.visible = false;
				view.GPSTextArea.includeInLayout = false;
				
				if(_gpsDataModel.gpsActivated == true && _gpsDataModel.gpsSupported == true)
				{
					view.busyIndicator.visible = true;
					view.gpsTextLabel.visible = true;
					view.findLocationButton.enabled = false;
					view.shutdownGeolocationButton.enabled = true;
				}
				else
				{
					view.busyIndicator.visible = false;
					view.gpsTextLabel.visible = false;
					view.findLocationButton.enabled = true;
					view.shutdownGeolocationButton.enabled = false;
				}
				
				delete dict["startViewSettings"];	
			}
			
			if(dict["networkService"])
			{
				populateTitleWindow("Service connection lost. Restart app!");
				
				delete dict["networkService"];
			}			
			
			if(dict["cookiesDeleted"])
			{
				populateTitleWindow("Cookies Deleted");	
				delete dict["cookiesDeleted"];
			}
			
			if(dict["geolocation"] == false)
			{
				view.busyIndicator.visible = false;
				view.gpsTextLabel.visible = false;
				view.findLocationButton.enabled = true;	
				view.shutdownGeolocationButton.enabled = false;
				
				delete dict["geolocation"];
			}
			
			if(dict["addressTextAreaVisible"])
			{
				view.addressTextArea.includeInLayout = true;
				view.addressTextArea.visible = true;
			}
			
			if(dict["gpsTextAreaVisible"])
			{
				_resizeEffect1.play();
				view.GPSTextArea.includeInLayout = true;
				view.GPSTextArea.visible = true;
				_resizeEffect2.play();					
			}
			
			if(dict["setResizeEffect"])
			{
				_resizeEffect1 = new Resize(view.addressTextArea);
				_resizeEffect1.heightFrom = 0;
				_resizeEffect1.heightTo = 60;
				_resizeEffect1.duration = 750;
				
				_resizeEffect2 = new Resize(view.GPSTextArea);
				_resizeEffect2.heightFrom = 0;
				_resizeEffect2.heightTo = 219;
				_resizeEffect2.duration = 750;					
			}
		}		
	}
}