package
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;

	public class CLParams
	{
		
		public static const DEFAULT: String = "default";
		public static const SPRITE_SHEET: String = "spriteSheet";
		public static const DEST_FOLDER: String = "destFolder";
		public static const CONFIG_FILE_FORMAT: String = "configFileFormat";
		private var params: Dictionary = new Dictionary();
		public function CLParams()
		{
			params[SPRITE_SHEET] = DEFAULT;
			params[DEST_FOLDER] = "";// File.applicationDirectory;
			params[CONFIG_FILE_FORMAT] = "txt";
		}
		
		public function setParam(paramID: String, paramValue: String): void {
			if (!params[paramID]) {
				throw new Error("Invalid Parameter");
			}
			params[paramID] = paramValue;
		}
		
		public function getParam(paramID: String): String {
			return params[paramID];
		}
	}
}