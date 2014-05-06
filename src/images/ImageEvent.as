package images
{
	import flash.events.Event;
	
	public class ImageEvent extends Event
	{
		public static const IMAGE_LOADED: String = "IMAGE_LOADED";
		public static const LAST_IMAGE_LOADED: String = "LAST_IMAGE_LOADED";
		public static const LAST_IMAGE_FAILED: String = "LAST_IMAGE_FAILED";

		private var _image: Image;
		public function ImageEvent(type:String, image: Image, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_image = image;
		}
		
		public function get image():Image
		{
			return _image;
		}

		override public function clone():Event {
			return new ImageEvent(type, _image, bubbles, cancelable);
		}
	}
}