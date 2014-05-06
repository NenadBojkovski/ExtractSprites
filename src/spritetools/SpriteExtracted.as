package spritetools
{
	import flash.geom.Rectangle;

	public class SpriteExtracted {
		private static var ID_COUNTER: int;
		public var id: int;
		public var rect: Rectangle;
		public var pixels: Vector.<Pixel>;

		public function SpriteExtracted() {
			id = ID_COUNTER ++;
			rect = new Rectangle();
			pixels = new Vector.<Pixel>();
		}
		
		public function merge(mergingSprite: SpriteExtracted, mergePixels: Boolean = true): void {
			var mergingRect: Rectangle = mergingSprite.rect;
			rect.left = Math.min(rect.left, mergingRect.left);
			rect.right = Math.max(rect.right, mergingRect.right);
			rect.top = Math.min(rect.top, mergingRect.top);
			rect.bottom = Math.max(rect.bottom, mergingRect.bottom);
			if (mergePixels) {
				var mergingPixels: Vector.<Pixel> = mergingSprite.pixels;
				var len: int = mergingPixels.length;
				var pixel: Pixel;
				for (var i: int = 0; i < len; ++i) {
					pixel = mergingPixels[i];
					pixel.sprite_id = id;
					pixels.push(pixel);
				}
			}
			mergingSprite.rect = rect;
			mergingSprite.id = id;
			mergingSprite.pixels = pixels;
		}
	}
}