package 
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.nudoru.components.RadialProgressBar;
	import com.nudoru.nori.events.InitProgressEvent;
	import com.nudoru.noriplugins.appview.AbstractContextLoader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;

	
	
	/**
	 * View for a nori loader
	 * @author Matt Perkins
	 */
	public class NoriLoader extends AbstractContextLoader
	{
		
		
		protected var _loadedContent		:Sprite;
		protected var _preloader			:PreLoaderClip;
		protected var _preloaderData		:Sprite;
		
		protected var _loadProgress			:RadialProgressBar;
		protected var _contentProgress		:RadialProgressBar;
		
		/**
		 * Constructor
		 */
		public function NoriLoader():void
		{
			super();
			
			load("player.swf");
		}

		/**
		 * Creates the preloader ui
		 */
		override protected function createLoadingView():void
		{
			super.createLoadingView();
			
			// Set alignment and disable scaling
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_preloader = new PreLoaderClip();
			_preloaderData = new Sprite();

			_loadProgress = new RadialProgressBar();
			_loadProgress.x = 0;
			_loadProgress.y = 0;
			_loadProgress.initialize({
				radius:50,
				size:10,
				barcolor:0x333333, 
				progress:0,
				border:-5
			});
			_loadProgress.segments = 30;
			_loadProgress.render();
			
			_contentProgress = new RadialProgressBar();
			_contentProgress.x = 15;
			_contentProgress.y = 15;
			_contentProgress.initialize({
				radius:35,
				size:10,
				barcolor:0xaaaaaa, 
				progress:0,
				border:-5
			});
			_contentProgress.segments = 30;
			_contentProgress.render();
			
			_preloaderData.addChild(_loadProgress);
			_preloaderData.addChild(_contentProgress);
			
			_preloader.addChild(_preloaderData);
			
			this.addChild(_preloader);

			this.stage.addEventListener(Event.RESIZE, onWindowResize);
			
			onWindowResize();
		}

		override protected function onLoadProgress(event:ProgressEvent):void 
		{
			//dispatchProgressEvent(calculatePercentage(event.bytesLoaded, event.bytesTotal));
			_loadProgress.progress = (event.bytesLoaded / event.bytesTotal)*100;
			
			if(_loadProgress.progress == 100) fadeOutMainLoader();
		}

		private function fadeOutMainLoader():void
		{
			TweenMax.to(_loadProgress, 1, {autoAlpha:0, blurFilter:{blurX:10, blurY:10}});
		}

		override protected function onContentProgress(event:InitProgressEvent):void
		{
			_contentProgress.progress = event.percentage;
			
			if (event.percentage == 100) fadeOutAllLoaders();
		}

		override protected function removeContentListeners():void
		{
			super.removeContentListeners();
			
			this.stage.removeEventListener(Event.RESIZE, onWindowResize);
		}
		
		protected function fadeOutAllLoaders():void
		{
			removeContentListeners();
			
			TweenMax.to(_preloader.bg_mc, .25, { autoAlpha:0, ease:Expo.easeOut } );
			//TweenMax.to(_loadProgress, .25, { autoAlpha:0, ease:Expo.easeOut, blurFilter:{blurX:10, blurY:10} } );
			TweenMax.to(_contentProgress, .25, { autoAlpha:0, ease:Expo.easeOut, blurFilter:{blurX:10, blurY:10}, onComplete:removeLoader } );
		}
		
		protected function removeLoader():void
		{
			_preloaderData.removeChild(_loadProgress);
			_preloaderData.removeChild(_contentProgress);
			
			_loadProgress.destroy();
			_contentProgress.destroy();
			
			_preloader.removeChild(_preloaderData);
			
			this.removeChild(_preloader);
			
			_loadProgress = undefined;
			_contentProgress = undefined;
			_preloaderData = undefined;
			_preloader = undefined;
		}
		
		protected function onWindowResize(e:Event = undefined):void
		{
			_preloader.bg_mc.scaleX = this.stage.stageWidth * .01;
			_preloader.bg_mc.scaleY = this.stage.stageHeight * .01;
			
			_preloaderData.x = int((this.stage.stageWidth / 2) - (_preloaderData.width / 2));
			_preloaderData.y = int((this.stage.stageHeight / 2) - (_preloaderData.height / 2));
		}
		
	}
	
}