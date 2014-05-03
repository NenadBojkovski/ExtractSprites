package spritesheet_pckg
{
	import flash.events.Event;
	
	public class SpriteSheetEvent extends Event
	{
		public static const SPRITE_SHEET_AVAILABLE: String = "SPRITE_SHEET_AVAILABLE";
		
		private var _spriteSheet: SpriteSheet;
		public function SpriteSheetEvent(type:String, spriteSheet: SpriteSheet, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_spriteSheet = spriteSheet;
		}
		
		public function get spriteSheet():SpriteSheet
		{
			return _spriteSheet;
		}

		override public function clone():Event {
			return new SpriteSheetEvent(type, _spriteSheet, bubbles, cancelable);
		}
	}
}