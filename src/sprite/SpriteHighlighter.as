package sprite
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	public class SpriteHighlighter extends Sprite
	{
		public function SpriteHighlighter()
		{
		}
		
		public function highlightSprites(sprites: Vector.<SpriteExtracted>): void {
			graphics.clear();
			graphics.lineStyle(1);
			var spriteRect: Rectangle;
			var len: int = sprites.length;
			for (var i:int = 0; i < len; ++i) {
				spriteRect = sprites[i].rect;
				graphics.moveTo(spriteRect.left, spriteRect.top);
				graphics.lineTo(spriteRect.right - 1, spriteRect.top);
				graphics.lineTo(spriteRect.right - 1, spriteRect.bottom - 1);
				graphics.lineTo(spriteRect.left, spriteRect.bottom - 1);
				graphics.lineTo(spriteRect.left, spriteRect.top);
			}
			graphics.endFill();
		}
	}
}