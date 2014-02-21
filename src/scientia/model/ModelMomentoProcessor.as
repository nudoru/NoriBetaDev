package scientia.model
{
	import com.nudoru.debug.Debugger;
	import com.nudoru.utilities.StringUtilities;

	/**
	 * @author Matt Perkins
	 */
	public class ModelMomentoProcessor implements IModelMomentoProcessor
	{
		private var _model:IScientiaModel;

		public function ModelMomentoProcessor(model:IScientiaModel):void
		{
			_model = model;
		}

		public function getMomento():String
		{
			var m:String = "<s>";
			m += "<aen>" + String(Settings.audioEnable) + "</aen>";
			m += "<av>" + String(Settings.audioVolume) + "</av>";
			m += "<am>" + String(Settings.audioMute) + "</am>";
			m += "<cap>" + String(Settings.captions) + "</cap>";
			m += "<cs>" + _model.structureVO.getCurrentScreen().id + "</cs>";
			m += "<scr>" + _model.structureVO.getAllScreenStatusString() + "</scr>";
			m += "</s>";
			var encoded:String = StringUtilities.compressBase64(m);
			return encoded;
		}

		/**
		 * Process a saved state string to return the model to the saved state/progress.
		 * 
		 * @param	data	Previously saved state/progress information
		 * @return	True if the data was read successfully, false if not
		 */
		public function processMomento(data:String):Boolean
		{
			// on resuming from some LMS system, "+" chars may be replaced with " " chars
			data = data.replace(/\s+/g, "+");
			var decode:String;

			// if there is an error decompressing the string, don't fail, catch the error and start at the beginning ignoring it
			try
			{
				decode = StringUtilities.decompressBase64(data);
			}
			catch (e:*)
			{
				Debugger.instance.add("ERROR DECODING MOMENTO", this);
				return false;
			}

			// sometimes (always?) there is garbage data at the start of the string, this will trim that out
			if(decode.indexOf("<s>") != 0) decode = decode.substr(decode.indexOf("<s>"), decode.length);

			var xmlData:XML = new XML(decode);

			Settings.audioEnable = (xmlData.aen == "true");
			Settings.audioVolume = Number(xmlData.av);
			Settings.audioMute = (xmlData.am == "true");
			Settings.captions = (xmlData.cap == "true");

			setScreenStatusFromResumeData(xmlData.scr);

			return true;
		}

		private function setScreenStatusFromResumeData(data:String):void
		{
			var screens:Array = data.split(",");
			for(var i:int = 0,len:int = screens.length;i < len;i++)
			{
				var screenData:Array = screens[i].split(":");
				if(screenData[0])
				{
					_model.setScreenIDStatusInteractionObject(screenData[0], screenData[1], undefined);
				}
			}
		}
	}
}
