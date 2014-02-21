package
{
	import com.nudoru.noriplugins.appview.AbstractContextMain;
	import scientia.context.Scientia;

	/**
	 * YOU MUST ENABLE EXPORT SWC IN THE FLA'S PUBLISH OPTIONS FOR THE NORI FRAMEWORK TO WORK PROPERLY
	 * See: http://www.patrickmowrer.com/2010/03/03/compiling-custom-as3-metadata-flash-professional
	 * 
	 * @author Matt Perkins
	 */
	public class Main extends AbstractContextMain
	{
		protected var _player:Scientia;

		public function Main():void
		{
			_player = new Scientia();
			_player.contextInitialzedSignal.addOnce(onNoriInitialized);
			_player.initialize(this);
		}

		protected function onNoriInitialized():void
		{
			_player.run();
		}
	}
}