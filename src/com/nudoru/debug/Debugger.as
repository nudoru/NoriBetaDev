package com.nudoru.debug {
	
	import flash.text.TextField;
	import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 * Debug Log class
	 * Last updated 3.31.09
	 * Matt Perkins
	 */
	public class Debugger {
		
		static private var _Instance	:Debugger;
		
		private var _Initd			:Boolean;
		private var _DebugText		:Array;
		private var _OutputField	:TextField;
		private var _Verbose		:Boolean;
	
		/**
		 * References to MonsterDebugger
		 */
		private var _MDebugger		:MonsterDebugger;
		private var _MDebuggerTarget:*;
		
		/**
		 * Get an instance of the Debugger
		 */
		public static function get instance():Debugger {
			if (Debugger._Instance == null) {
				Debugger._Instance = new Debugger(new SingletonEnforcer());
				Debugger._Instance.init();
			}
			return Debugger._Instance;
		}
		
		/**
		 * @private
		 */
		public function Debugger(singletonEnforcer:SingletonEnforcer) {}
	
		/**
		 * @private
		 */
		public function init():void {
			if(!_DebugText) _DebugText = new Array();
			_Verbose = true;
			_Initd = true;
		}
		
		/**
		 * Initialize monster debugger
		 * @param	what	initial/default target
		 */
		public function initializeMDebugger(what:*):void
		{
			_MDebuggerTarget = what;
			_MDebugger = new MonsterDebugger(_MDebuggerTarget);
		}
		
		/**
		 * Add a text to the log
		 * @param	txt	Text to add
		 * @param	target	Where the text came from
		 */
		public function add(txt:String, target:*=undefined):void {
			if (!_Initd) init();
			_DebugText.push(txt);
			
			if (_MDebuggerTarget || target)
			{
				MonsterDebugger.trace(target ? target : _MDebuggerTarget, txt);
			}
			
			updateOutputField();
			if(_Verbose) trace("# "+txt);
		}
		
		/**
		 * Set a text field to display the log as items are added
		 * @param	f	TextField to display text in
		 */
		public function setOutputField(f:TextField):void {
			_OutputField = f;
		}
	
		private function updateOutputField():void {
			if(!_OutputField) return;
			_OutputField.text = "";
			var len:int = _DebugText.length-1;
			for(var i:int = len; i>0; i--) {
				_OutputField.appendText(_DebugText[i]+"\n");
			}
		}
	
	}
	
}

class SingletonEnforcer {}