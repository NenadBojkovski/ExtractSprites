package
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;

	import utils.Logger;

	public class CLParams
	{
		
		public static const SRC_FILE: String = "srcFile";
		public static const SRC_FOLDER: String = "srcFolder";
		public static const DEST_FOLDER: String = "destFolder";
		public static const DECOMPOSE: String = "decompose";  //"t" - true, "f" - false
		public static const CONFIG_FILE_FORMAT: String = "configFileFormat";

		private var availableArguments: Array = [SRC_FILE, DEST_FOLDER, CONFIG_FILE_FORMAT, SRC_FOLDER, DECOMPOSE];
		private var params: Dictionary = new Dictionary();
		//if the commandline params are provided.
		private var _clMode: Boolean = false;

		private static var _instance: CLParams;
		private static var _canBeInstantiated: Boolean;

		public function CLParams()
		{
			if (!_canBeInstantiated) {
				throw new Error("CLParams is singleton!");
			}
			params[DEST_FOLDER] = File.documentsDirectory.nativePath + File.separator + "sprites";
			params[CONFIG_FILE_FORMAT] = "txt";
			params[DECOMPOSE] = "t";
		}

		public static function getInstance(): CLParams {
			if (!_instance) {
				_canBeInstantiated = true;
				_instance = new CLParams();
				_canBeInstantiated = false;
			}
			return _instance;
		}
		
		public function getParam(paramID: String): String {
			return params[paramID];
		}

		public function apply(arguments: Array): void {
			var len: int = arguments.length;
			_clMode = len > 0;
			Logger.log("Command line mode: "+_clMode);
			var errorText: String;
			var argument: Array;
			var argumentID: String;
			var argumentValue: String;
			for (var i: int = 0; i < len; ++i) {
				argument = arguments[i].split("=");
				argumentID = argument[0];
				argumentValue = argument[1];
				if (availableArguments.indexOf(argumentID) > -1){
					params[argumentID] = argumentValue;
					Logger.log("Arguments "+argumentID +" = "+argumentValue);
				} else {
					errorText = argumentID + " does not exist!";
					Logger.error(errorText);
					throw  new Error(errorText);
				}

			}
			if (_clMode && !params[SRC_FOLDER] && !params[SRC_FILE]) {
				errorText = "There is no file or folder chosen!";
				Logger.error(errorText);
				throw  new Error(errorText);
			}
		}

		public function get clMode(): Boolean {
			return _clMode;
		}
	}
}