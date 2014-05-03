package
{
	import com.adobe.images.PNGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	[SWF(height="2048", width="2048")]
	public class ExtractSprites extends Sprite
	{
		//[Embed(source="../assets/SpriteSheet.png")]
		//[Embed(source="../assets/SpriteSheet1.png")]
		//[Embed(source="../assets/SpriteSheet2.png")]
		//[Embed(source="../assets/SpriteSheet3.png")]
		[Embed(source="../assets/sprites_2.png")]
		private var spriteSheet:Class;
		private var spriteDict: Dictionary;
		private var vSpacing: int;
		private var hSpacing: int;
		private var rectangles: Sprite;
		
		public function ExtractSprites()
		{
			spriteDict = new Dictionary();
			var bmp: Bitmap = new spriteSheet();
			var bmpData: BitmapData = bmp.bitmapData;
			addChild(bmp);
			addChild(rectangles = new Sprite());
			extractSprites(bmpData);
			exportSprites(bmpData);
		}
		
		private function exportSprites(bmpData: BitmapData): void
		{
			var exportingSprites: Vector.<SpriteExtracted> = new Vector.<SpriteExtracted>();
			for each (var sprite: SpriteExtracted in spriteDict) {
				exportingSprites.push(sprite);
			}
			
			var spriteName: String = "SpriteSheet";
			var appPath: String = File.applicationDirectory.nativePath;
			var s: String = File.separator;
			var filePrefix: String = appPath + s + ".." + s +"assets" + s + spriteName + s + spriteName + "_ ";
			var ba:ByteArray;
			var zeroPoint: Point = new Point();
			var rect: Rectangle;
			var pngSource:BitmapData;
			var len: int = exportingSprites.length;
			for (var i: int = 0; i < len; ++i) { 
				rect = exportingSprites[i].rect;
				pngSource = new BitmapData (rect.width, rect.height, true, 0x00000000);
				pngSource.copyPixels(bmpData, rect, zeroPoint);
				ba = PNGEncoder.encode(pngSource);
				var file:File = new File(filePrefix + i + ".png");
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeBytes(ba);
				fileStream.close();	
				pngSource.dispose();
			}
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
			
			trace("Image analyzing time: " + (getTimer() - now) + " ms.");
			var mergingSprites: Vector.<SpriteExtracted> = new Vector.<SpriteExtracted>();
			for each (sprite in spriteDict) {
				mergingSprites.push(sprite);
			}
			trace("Num of sprites "+ mergingSprites.length)
			now = getTimer();
			var spriteI: SpriteExtracted;
			var spriteIid: int;
			var spriteJ: SpriteExtracted;
			var spriteJid: int;
			for (var i: int = mergingSprites.length - 1; i > -1; --i) {
				spriteI = mergingSprites[i];
				spriteIid = spriteI.id;
				for (var j: int = mergingSprites.length - 1; j > -1; --j) {
					spriteJ = mergingSprites[j];
					spriteJid = spriteJ.id;
					if (spriteIid != spriteJid && spriteI.rect.intersects(spriteJ.rect)) {
						delete spriteDict[spriteIid];	
						spriteJ.merge(spriteI,false);
						spriteDict[spriteJ.id] = spriteJ;
					}
				}
			}
			
			trace("Merging overlapping sprites time: " + (getTimer() - now) + " ms.");
			
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

class Pixel {
	public var sprite_id: int;
	
	public function Pixel(sprite_id: int) {
		this.sprite_id = sprite_id;
	}
}