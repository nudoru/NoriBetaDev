  package com.nudoru.nori.events.signals
{
	import com.nudoru.nori.mvc.view.IAbstractNoriView;
	import org.osflash.signals.Signal;
	
	/**
	 * Globally available signals pertaining to audio
	 * @author Matt Perkins
	 */
	public class AbstractViewSignals
	{
		public static var ADDED_TO_STAGE				:Signal = new Signal(IAbstractNoriView);
		public static var REMOVED_FROM_STAGE			:Signal = new Signal(IAbstractNoriView);
	}
}
