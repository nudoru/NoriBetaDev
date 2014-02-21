package com.nudoru.components
{

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * Loads an XML file
	 * 
	 * Sample:
	 * 
		import com.nudoru.components.XMLLoader;
		import com.nudoru.components.NudoruComponentEvent;

		var xl:XMLLoader = new XMLLoader();
		xl.initialize({url:"assets/sample.xml"});
		xl.addEventListener(NudoruComponentEvent.EVENT_PROGRESS, onXMLProgress);
		xl.addEventListener(NudoruComponentEvent.EVENT_LOADED, onXMLLoaded);
		xl.addEventListener(NudoruComponentEvent.EVENT_PARSE_ERROR, onXMLError);
		xl.addEventListener(NudoruComponentEvent.EVENT_IOERROR, onXMLError);
		xl.load();

		function onXMLProgress(event:NudoruComponentEvent):void
		{
			trace(event.data)
		}

		function onXMLLoaded(event:Event):void
		{
			trace(xl.content)
		}

		function onXMLError(event:Event):void
		{
			trace("ERROR: "+event.type);
		}
	 */
	
	public class XMLLoader extends AbstractDataComponent implements IAbstractDataComponent
	{
		
		/**
		 * URL of the file to load
		 */
		protected var _url:String;
		protected var _loader:URLLoader;
		
		/**
		 * The XML object loaded into XMLFileLoader. This property is null until the XMLFileLoaderEvent.LOAD_COMPLETE event is dispatched.
		 */
		protected var _xml:XML;
		
		/**
		 * The data loaded from the XML file
		 */
		override public function get content():*
		{
			return _xml;
		}
		
		/**
		 * Constructor
		 */
		public function XMLLoader():void
		{
			super();
		}
		
		/**
		 * Initialize
		 */
		override public function initialize(data:*=null):void 
		{			
			_url = data.url;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Begins loading the XML file
		 */
		override public function load():void 
		{
			dispatchProgressEvent(0);
			
			_loader = new URLLoader(new URLRequest(_url));
			_loader.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true); 
			_loader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress, false, 0, true); 
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false, 0, true);
		}

		/**
		 * File not found
		 * @param	event
		 */
		protected function onLoadError(event:IOErrorEvent):void 
		{
			removeListeners();
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_IOERROR));
		}
		
		protected function onLoadProgress(event:ProgressEvent):void
		{
			dispatchProgressEvent(calculatePercentage(event.bytesLoaded, event.bytesTotal));
		}
		
		protected function onLoadComplete(event:Event):void
		{
			removeListeners();
			
			try {
				_xml = new XML(event.target.data);
			} catch (event:*) {
				dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_PARSE_ERROR));
				return;
			}
			
			dispatchProgressEvent(100);
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_LOADED));
		}
		
		protected function removeListeners():void
		{
			_loader.removeEventListener(Event.COMPLETE, onLoadComplete); 
			_loader.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress); 
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		}
		
		override public function destroy():void
		{
			removeListeners();
			
			try {
				_loader.close();
			} catch(e:*) {}
			
			_loader = null;
			_xml = null;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
		
	}
	
}