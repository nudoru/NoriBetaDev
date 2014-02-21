package scientia.controller.commands 
{
	import com.nudoru.debug.Debugger;
	import com.nudoru.nori.mvc.controller.commands.AbstractCommand;
	import com.nudoru.nori.mvc.controller.commands.IAbstractCommand;
	import net.stevensacks.utils.Web;

	
	/**
	 * This is template to quickly create a new command
	 */
	public class GoURLCommand extends AbstractCommand implements IAbstractCommand
	{
		public function GoURLCommand():void
		{
			super();
		}
		
		/**
		 * Do something
		 */
		override public function execute():void {
			Debugger.instance.add("GoURLCommand, execute: "+data[0]);
			Web.getURL(data[0], "_blank");
		}
		
	}

}