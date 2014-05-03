package utils
{
	import flash.display.Sprite;
	import flash.text.TextField;

	public class Logger extends Sprite
	{
		private static var _console: TextField = new TextField();
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
			_console.appendText(str +"\n");
		}
	}
}