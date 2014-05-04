package utils
{
	import flash.display.Sprite;
	import flash.text.TextField;

	public class Logger extends Sprite
	{
		private static var _console: TextField = new TextField();
		private static var _errorLog: String = "";
		private static var _warningLog: String = "";
		private static var _normalLog: String = "";
		public static function init(): void
		{
			_console.x = 15; 
			_console.y = 15; 
			_console.width = 520; 
			_console.height = 520; 
		}
		
		public static function get console():TextField
		{
			return _console;
		}

		public static function log(str: String): void{
			trace(str);
			var logText: String = (str +"\n");
			_normalLog += logText;
			_console.appendText(logText);
			_console.scrollV = _console.maxScrollV;
		}

		public static function error(str: String): void{
			trace("ERROR!" + str);
			var logText: String = (str +"\n");
			_errorLog += logText;
			_console.appendText(logText);
		}

		public static function warning(str: String): void{
			trace("WARNING!" + str);
			var logText: String = (str +"\n");
			_warningLog += logText;
			_console.appendText(logText);
		}

		public static function get normalLog(): String {
			return _normalLog;
		}

		public static function get errorLog(): String {
			return _errorLog;
		}

		public static function get warningLog(): String {
			return _warningLog;
		}
	}
}