package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	[SWF(height="2048", width="2048")]
	public class ExtractSprites extends Sprite
	{
		//[Embed(source="../assets/SpriteSheet2.png")]
		[Embed(source="../assets/sprites_2.png")]
		private var spriteSheet:Class;
		private var spriteDict: Dictionary;
		private var vSpacing: int;
		private var hSpacing: int;
		private var rectangles: Sprite;
		
		public function ExtractSprites()
		{
			super();
			spriteDict = new Dictionary();
			var bmp: Bitmap = new spriteSheet();
			var bmpData: BitmapData = bmp.bitmapData;
			addChild(bmp);
			addChild(rectangles = new Sprite());
			extractSprites(bmpData);
		}
		
		private function extractSprites(bmpData:BitmapData):void
		{
			var now: Number = getTimer();
			var ssWidth: int = bmpData.width;
			var ssHeight: int = bmpData.height;
			var pixels: Vector.<Vector.<Pixel>> = new Vector.<Vector.<Pixel>>(ssHeight, true);
			var yMinus1: int;
			var xMinus1: int;
			var noSprite: int = -1;
			var spriteId: int;
			var spriteRect: Rectangle;
			var sprite: SpriteExtracted;
			var pixel: Pixel;
			var neighbourSpriteId: int;
			var neighbourSpriteRect: Rectangle;
			var neighbourSprite: SpriteExtracted;
			var neighbourPixel: Pixel;
			for (var y: int = 0; y < ssHeight; ++y){
				pixels[y] = new Vector.<Pixel>(ssWidth, true);
				for (var x: int = 0; x < ssWidth; ++x) {
					if(bmpData.getPixel32(x, y) != 0){
						spriteId = noSprite;
						if(x > 0) {
							xMinus1 = x - 1;
							neighbourPixel = pixels[y][xMinus1];
							neighbourPixel && (spriteId = neighbourPixel.sprite_id);
						}
						if(y > 0) {
							yMinus1 = y - 1;
							if (x > 0){
								neighbourPixel = pixels[yMinus1][xMinus1];
								if (neighbourPixel) {
									neighbourSpriteId = neighbourPixel.sprite_id;
									if (spriteId != noSprite && spriteId != neighbourSpriteId){
										spriteDict[neighbourSpriteId].merge(spriteDict[spriteId]);
										delete spriteDict[spriteId];
									}
									spriteId = neighbourSpriteId;
								}
							}
							
							neighbourPixel = pixels[yMinus1][x];
							if (neighbourPixel) {
								neighbourSpriteId = neighbourPixel.sprite_id;
								if (spriteId != noSprite && spriteId != neighbourSpriteId){
									spriteDict[neighbourSpriteId].merge(spriteDict[spriteId]);
									delete spriteDict[spriteId];
								}
								spriteId = neighbourSpriteId;
							}
							
							if (x < ssWidth - 1){
								neighbourPixel = pixels[yMinus1][x + 1]
								if (neighbourPixel) {
									neighbourSpriteId = neighbourPixel.sprite_id;
									if (spriteId != noSprite && spriteId != neighbourSpriteId){
										spriteDict[neighbourSpriteId].merge(spriteDict[spriteId]);
										delete spriteDict[spriteId];
									}
									spriteId = neighbourSpriteId;
								}
							}							
						}
						
						if( spriteId == noSprite) {
							sprite = new SpriteExtracted();
							spriteId = sprite.id;
							spriteDict[spriteId] = sprite;
							spriteRect = sprite.rect;
							spriteRect.left = x - hSpacing;
							spriteRect.right = x + hSpacing + 1;
							spriteRect.top = y - vSpacing;
							spriteRect.bottom = y + vSpacing + 1;
						} else {
							sprite = spriteDict[spriteId];
							spriteRect = sprite.rect;
							spriteRect.left = Math.min(spriteRect.left, x - hSpacing);
							spriteRect.right = Math.max(spriteRect.right, x + hSpacing + 1);
							spriteRect.top = Math.min(spriteRect.top, y - vSpacing);
							spriteRect.bottom = Math.max(spriteRect.bottom, y + vSpacing + 1);
						}
						pixel = new Pixel(spriteId);
						pixels[y][x] = pixel;
						sprite.pixels.push(pixel);
					
					}
					
				}
			}
			
			trace("Image analyzing time: " + (getTimer() - now));
			var mergingSprites: Vector.<SpriteExtracted> = new Vector.<SpriteExtracted>();
			for each (sprite in spriteDict) {
				mergingSprites.push(sprite);
			}
			trace("Num of sprites "+ mergingSprites.length)
			var graphics: Graphics = rectangles.graphics;
			graphics.clear();
			graphics.lineStyle(1);
			for each (sprite in spriteDict) {
				spriteRect = sprite.rect;
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
import flash.geom.Rectangle;

class SpriteExtracted {
	private static var ID_COUNTER: int;
	public var id;
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
	}
}

class Pixel {
	public var sprite_id: int;
	
	public function Pixel(sprite_id: int) {
		this.sprite_id = sprite_id;
	}
}