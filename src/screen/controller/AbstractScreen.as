package screen.controller
{
	import com.nudoru.utilities.AccUtilities;
	import screen.events.signals.ScreenStatusSignals;
	import com.nudoru.lms.scorm.InteractionObject;
	import com.nudoru.components.IWindow;
	import screen.events.signals.ScreenDisplaySignals;
	import com.nudoru.components.Button;
	import screen.model.IAbstractScreenModel;
	import com.nudoru.components.SheetView;
	import flash.display.*;
	import flash.events.*;
	
	import com.nudoru.components.TextBox;
	import com.nudoru.components.WindowManager;
	import com.nudoru.components.IWindowManager;
	import com.nudoru.components.XMLLoader;
	import com.nudoru.components.ComponentEvent;
	
	import com.nudoru.debug.Debugger;
	
	/**
	 * Base functionality for a screen. Contains a lot of standardized code to ensure that interactions look similar
	 * 
	 * This combines functions of a controller and view while the data is kept in a model
	 */
	public class AbstractScreen extends Sprite implements IAbstractScreen
	{
		//---------------------------------------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------------------------------------
		
		/**
		 * Is the screen running since of a screen manager framework?
		 */
		protected var _RunningInFramework	:Boolean = false;
		/**
		 * Data passed to the screen on initialization
		 */
		protected var _InitData				:Object;
		/**
		 * XML File to load for the interactions's content
		 */
		protected var _XMLFile				:String;
		/**
		 * NudoruComponent to load the content XML file
		 */
		protected var _XMLLoader			:XMLLoader;
		/**
		 * Manages any popup windows
		 * If running in a framwork, the framework's screen will be injected 
		 */
		protected var _SWindowManager		:IWindowManager; 
		/**
		 * Window currently displayed
		 */
		protected var _CurrentMessageWindow :IWindow;
		/**
		 * Is the window manager from the framework?
		 */
		protected var _FrameworkWM			:Boolean = false;
		/**
		 * Common content - title, text, cta
		 */
		protected var _ContentLayer			:Sprite;
		/**
		 * Nudoru Sheet Component holder
		 */
		protected var _SheetView			:SheetView;
		/**
		 * Dynamic content rendered here
		 */
		protected var _InteractionLayer		:Sprite;
		/**
		 * Previous completion status - last time the screen was completed
		 */
		protected var _PreviousCompletionStatus	:int;
		/**
		 * Previous interaction object - last time the screen was completed
		 */
		protected var _PreviousInteractionObject:InteractionObject;
		
		/**
		 * Text areas
		 */
		protected var _TitleTextTB			:TextBox;
		protected var _BodyTextTB			:TextBox;
		protected var _CTATextTB			:TextBox;
		

		//---------------------------------------------------------------------
		//
		//	GETTER/SETTER
		//
		//---------------------------------------------------------------------
		
		
		public function get windowManager():IWindowManager
		{
			return _SWindowManager;
		}

		[Inject]
		public function set windowManager(value:IWindowManager):void
		{
			_SWindowManager = value;
		}
		
		public function get screenWidth():int
		{
			return 810;
		}
		
		public function get screenHeight():int
		{
			return 485;
		}

		public function get screenBorder():int
		{
			return 20;
		}

		//---------------------------------------------------------------------
		//
		//	CONSTRUCTION
		//
		//---------------------------------------------------------------------
		
		public function AbstractScreen()
		{
			ScreenDisplaySignals.LOADED.dispatch();
			
			// test to see if loaderInfo is available
			try 
			{
				// this will error if it's not on the display list
				if (this.stage.loaderInfo)
				{
					_RunningInFramework = false;
					// start running the screen
					initialize({xmlurl:getXMLFileName()});
				}
			}
			catch (e:*)
			{
				_RunningInFramework = true;
			}
		
			//Debugger.instance.add("Running in a framework? " + _RunningInFramework, this);
		}
		
		//---------------------------------------------------------------------
		//
		//	INITIALIZATION
		//
		//---------------------------------------------------------------------
		
		/**
		 * Initialize the screen
		 * 
		 * initialize( { status:currentScreenVO.status, 
		 * 				interobj:currentScreenVO.interactionObject, 
		 * 				xmlurl:currentScreenVO.dataURL } );
		 * @param	data
		 */
		public function initialize(data:*=undefined):void
		{			
			createViewlayers();
			setupWindowManager();
	
			if (data is Object) configureFrameworkData(data);
	
			beginLoadingXMLFile();
		}

		private function createViewlayers():void
		{
			_ContentLayer = new Sprite();
			
			_InteractionLayer = new Sprite();
			
			_SheetView = new SheetView();
			_SheetView.initialize();
			
			this.addChild(_ContentLayer);
			this.addChild(_SheetView);
			this.addChild(_InteractionLayer);
		}

		private function setupWindowManager():void
		{
			// If a framework didn't inject the window manager, create one
			if(!windowManager)
			{
				_SWindowManager = new WindowManager();
				_SWindowManager.initialize();
				_SWindowManager.render();
				this.addChild(_SWindowManager as DisplayObject);
			}
			else
			{
				_FrameworkWM = true;
			}
		}

		private function configureFrameworkData(data:Object):void
		{
			_InitData = data;
			if(data.xmlurl) _XMLFile = data.xmlurl;
			if(data.status) _PreviousCompletionStatus = data.status;
			if(data.interobj) _PreviousInteractionObject = data.interobj;
		}

		private function beginLoadingXMLFile():void
		{
			_XMLLoader = new XMLLoader();
			_XMLLoader.initialize({url:_XMLFile});
			_XMLLoader.addEventListener(ComponentEvent.EVENT_PROGRESS, onXMLProgress, false, 0, true);
			_XMLLoader.addEventListener(ComponentEvent.EVENT_LOADED, onXMLLoaded, false, 0, true);
			_XMLLoader.addEventListener(ComponentEvent.EVENT_PARSE_ERROR, onXMLError, false, 0, true);
			_XMLLoader.addEventListener(ComponentEvent.EVENT_IOERROR, onXMLError, false, 0, true);
			_XMLLoader.load();
		}

		/**
		 * XML Loading 
		 * @param	event
		 */
		protected function onXMLProgress(event:ComponentEvent):void {}
		
		/**
		 * The XML file has finished loading
		 * @param	event
		 */
		protected function onXMLLoaded(event:Event):void
		{
			parseLoadedXML(_XMLLoader.content);
			destroyXMLLoader();

			ScreenDisplaySignals.INITIALIZED.dispatch();
			render();
		}

		/**
		 * Error loadin the XML file
		 * @param	event
		 */
		protected function onXMLError(event:Event):void
		{
			showMessage("Problem!", "Couldn't load the data file ('"+_XMLFile+"') because of error: '"+event.type+"'.<br><br>"+this.loaderInfo.url);
			Debugger.instance.add("ERROR: "+event.type, this);
			destroyXMLLoader();
		}

		/**
		 * Removes the XML loader and events
		 */
		protected function destroyXMLLoader():void
		{
			if(!_XMLLoader) return;
			_XMLLoader.removeEventListener(ComponentEvent.EVENT_PROGRESS, onXMLProgress);
			_XMLLoader.removeEventListener(ComponentEvent.EVENT_LOADED, onXMLLoaded);
			_XMLLoader.removeEventListener(ComponentEvent.EVENT_PARSE_ERROR, onXMLError);
			_XMLLoader.removeEventListener(ComponentEvent.EVENT_IOERROR, onXMLError);
			_XMLLoader.destroy();
			_XMLLoader = undefined;
		}

		/**
		 * Construct the model from the loaded XML
		 * @param	data
		 */
		protected function parseLoadedXML(data:XML):void
		{
			// assign a model, to be done in extended class
		}
		
		//---------------------------------------------------------------------
		//
		//	STATUS
		//
		//---------------------------------------------------------------------
		
		/**
		 * Set the screens status in a framework mode
		 * For scored interaction pages, if running in a framework, a status >= 2 should trigger the enabling of the Next button
		 * TODO - generate interaction object
		 */
		public function setScreenStatusTo(status:int, intObject:InteractionObject = undefined):void
		{
			switch(status)
			{
				case 0:
					break;
				case 1:
					ScreenStatusSignals.INCOMPLETE.dispatch();
					break;
				case 2:
					ScreenStatusSignals.COMPLETED.dispatch(intObject);
					break;
				case 3:
					ScreenStatusSignals.PASSED.dispatch(intObject);
					break;
				case 4:
					ScreenStatusSignals.FAILED.dispatch(intObject);
					break;
				default:
					Debugger.instance.add("Unknown screen status: "+status, this);
			}
		}
		
		//---------------------------------------------------------------------
		//
		//	RENDER
		//
		//---------------------------------------------------------------------
		
		/**
		 * Draws the view
		 */
		public function render():void
		{
			renderScreen();

			ScreenDisplaySignals.RENDERED.dispatch();
		}
		
		/**
		 * Draw specific screen views
		 */
		protected function renderScreen():void
		{	
			// used by extended class
		}
		
		
		//---------------------------------------------------------------------
		//
		//	COMMON GLOBAL VIEW
		//
		//---------------------------------------------------------------------

		/**
		 * Renders the title, bosy text, call to action and sheet elements
		 */
		protected function renderCommonScreenElements(screenmodel:IAbstractScreenModel):void
		{
			if(screenmodel.title) createTitleText(screenmodel.title);
			if(screenmodel.text) createBodyText(screenmodel.text);
			if(screenmodel.cta) createCTAText(screenmodel.cta);
			if(screenmodel.sheetXML) _SheetView.renderSheetFromXML(screenmodel.sheetXML);
		}
		
		/**
		 * Show the title text
		 * @param	text
		 */
		protected function createTitleText(text:String):void
		{
			_TitleTextTB = new TextBox();
			_TitleTextTB.initialize({
						width:screenWidth-(screenBorder*2),
						content:text,
						font:"Verdana",
						align:"left",
						size:22,
						color:0x000000
						});
			_TitleTextTB.render();
			
			_TitleTextTB.x = screenBorder;
			_TitleTextTB.y = screenBorder;
			
			_ContentLayer.addChild(_TitleTextTB);
		}
		
		/**
		 * Show the body text
		 * @param	text
		 */
		protected function createBodyText(text:String):void
		{
			_BodyTextTB = new TextBox();
			_BodyTextTB.initialize({
						width:screenWidth-(screenBorder*2),
						content:text,
						font:"Verdana",
						align:"left",
						size:12,
						color:0x000000
						});
			_BodyTextTB.render();
			
			_BodyTextTB.x = screenBorder;
			if(_TitleTextTB) _BodyTextTB.y = _TitleTextTB.y + _TitleTextTB.measure().height + screenBorder;
				else _BodyTextTB.y = screenBorder;
			
			_ContentLayer.addChild(_BodyTextTB);
		}
		
		/**
		 * Show the call to action (instructions) text
		 * @param	text
		 */
		protected function createCTAText(text:String):void
		{
			_CTATextTB = new TextBox();
			_CTATextTB.initialize({
						width:screenWidth-(screenBorder*2),
						content:text,
						font:"Verdana",
						align:"left",
						size:12,
						color:0x0000cc
						});
			_CTATextTB.render();
			
			_CTATextTB.x = screenBorder;
			_CTATextTB.y = screenBorder;
			
			if(_TitleTextTB && !_BodyTextTB) _CTATextTB.y = _TitleTextTB.y + _TitleTextTB.measure().height + screenBorder;			
			if(_BodyTextTB) _CTATextTB.y = _BodyTextTB.y + _BodyTextTB.measure().height + screenBorder;

			_ContentLayer.addChild(_CTATextTB);
		}
		
		/**
		 * Create a common screen button
		 */
		protected function createCommonButton(label:String, width:int = 100):Button
		{
			var button:Button = new Button();
			button.initialize({
						width:width,
						label:label,
						showface:true,
						facecolor:0x96172e,
						font:"Verdana",
						labelalign:"center",
						size:14,
						color:0xffffff,
						labelshadowcolor:0x671020,
						bordersize:1
						});
			button.render();
			return button;
			
			// disabled AccUtilities.setProperties(button, label);
		}
		
		//---------------------------------------------------------------------
		//
		//	POP UP WINDOWS
		//
		//---------------------------------------------------------------------

		/**
		 * Show a basic message
		 * @param	title
		 * @param	message
		 */
		protected function showMessage(title:String, message:String):void
		{
			if(_CurrentMessageWindow)
			{
				_CurrentMessageWindow.destroy();	
			}
			_CurrentMessageWindow = _SWindowManager.showMessage(title,message,true);
			_CurrentMessageWindow.addEventListener(ComponentEvent.EVENT_DESTROYED, onMessageWindowClosed, false, 0, true);
		}

		/**
		 * Event for the message window closing
		 */
		protected function onMessageWindowClosed(e:ComponentEvent):void
		{
			_CurrentMessageWindow.removeEventListener(ComponentEvent.EVENT_DESTROYED, onMessageWindowClosed);
			_CurrentMessageWindow = undefined;			
			handleMessageWindowClosed();
		}

		/**
		 * Perform functions when the window is closed
		 */
		protected function handleMessageWindowClosed():void
		{
			//
		}

		//---------------------------------------------------------------------
		//
		//	UTILITY
		//
		//---------------------------------------------------------------------

		/**
		 * Will parse the file name and look for a FlashVar to determine the XML file name
		 */
		protected function getXMLFileName():String
		{
			var xmlsrc:String = "";
			
			// gets the name of the SWF file
			try {
				var p:Array = this.loaderInfo.url.split("/");
				var f:String = p[p.length-1].split(".")[0];
				xmlsrc = f+".xml";
			} catch (e:*) { }
			
			// gets a flashvars xml file name
			var flashVars:Object = this.loaderInfo.parameters;
			if (flashVars.file) xmlsrc = unescape(flashVars.file);
			
			return xmlsrc.toLowerCase();
		}
		
		//---------------------------------------------------------------------
		//
		//	DESTROY
		//
		//---------------------------------------------------------------------
		
		/**
		 * Unload and remove events
		 */
		public function destroy():void
		{
			// remove the XML loader
			destroyXMLLoader();
			
			// remove text areas
			if (_TitleTextTB)
			{
				_TitleTextTB.destroy();
				_ContentLayer.removeChild(_TitleTextTB);
				_TitleTextTB = undefined;
			}
			if (_BodyTextTB)
			{
				_BodyTextTB.destroy();
				_ContentLayer.removeChild(_BodyTextTB);
				_BodyTextTB = undefined;
			}
			if (_CTATextTB)
			{
				_CTATextTB.destroy();
				_ContentLayer.removeChild(_CTATextTB);
				_CTATextTB = undefined;
			}
			
			// remove the sheet
			// TODO - wait for sheet to unload and then dispatch unloaded event. Will allow for screen elements to transition out
			_SheetView.destroy();
			this.removeChild(_SheetView);
			_SheetView = undefined;
			
			// remove the pop up window
			if(_CurrentMessageWindow)
			{
				_CurrentMessageWindow.destroy();	
			}
			
			// remove the window manager if it wasn't supplied by the framework
			if(!_FrameworkWM)
			{
				_SWindowManager.destroy();
				this.removeChild(_SWindowManager as DisplayObject);
			}
			_SWindowManager = undefined;
			
			// remove the layers
			this.removeChild(_ContentLayer);
			_ContentLayer = undefined;
			this.removeChild(_InteractionLayer);
			_InteractionLayer = undefined;
			
			removeAndDestroyAllChildren(this);
			
			ScreenDisplaySignals.UNLOADED.dispatch();
		}

		protected function removeAndDestroyAllChildren(container:DisplayObjectContainer):void
		{
			while(container.numChildren > 0)
			{
				var currentChild:* = container.getChildAt(0);
				if(currentChild.numChildren) removeAndDestroyAllChildren(currentChild);
				try
				{
					currentChild.destroy();
				} catch(e:*){}
				container.removeChildAt(0);
			}
		}

	}
}