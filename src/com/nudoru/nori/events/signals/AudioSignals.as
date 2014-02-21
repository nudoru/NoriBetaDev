  package com.nudoru.nori.events.signals
{
	import org.osflash.signals.Signal;
	
	/**
	 * Globally available signals pertaining to audio
	 * @author Matt Perkins
	 */
	public class AudioSignals
	{
		public static var GOTO_URL				:Signal = new Signal();
		public static var AUDIO_ENABLE			:Signal = new Signal();
		public static var AUDIO_DISABLE			:Signal = new Signal();
		public static var AUDIO_MUTE_ON			:Signal = new Signal();
		public static var AUDIO_MUTE_OFF		:Signal = new Signal();
		public static var AUDIO_VOLUME_CHANGE	:Signal = new Signal();
	}
}
