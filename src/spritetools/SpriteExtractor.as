package spritetools
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import images.Image;
	
	import utils.Logger;

	public class SpriteExtractor
	{
		public function SpriteExtractor()
		{
		}
		
		public function extractSprites(spriteSheet: Image, mergeOverlappingSprites: Boolean = true, hSpacing: int = 0, vSpacing: int = 0 ): Vector.<SpriteExtracted>
		{
			var now: Number = getTimer();
			var bmpData: BitmapData = spriteSheet.bmpData;
			var ssWidth: int = bmpData.width;
			var ssHeight: int = bmpData.height;
			var spriteDict: Dictionary = new Dictionary();
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
			
			Logger.log("Image analysing time: " + (getTimer() - now) + " ms.");
			if (mergeOverlappingSprites){
				now = getTimer();
				var spriteI: SpriteExtracted;
				var spriteIid: int;
				var spriteJ: SpriteExtracted;
				var spriteJid: int;
				var merged: Boolean;
				for each(spriteI in spriteDict){
					spriteIid = spriteI.id;
					merged = true;
					while (merged){
						merged = false;
						for each(spriteJ in spriteDict){
							spriteJid = spriteJ.id;
							if (spriteIid != spriteJid && spriteI.rect.intersects(spriteJ.rect)) {
								delete spriteDict[spriteJid];	
								spriteI.merge(spriteJ,false);
								merged = true;
								break;
							}
							
						} 
					}
				}
				Logger.log("Merging overlapping sprites time: " + (getTimer() - now) + " ms.");
			}
			
			var finalSprites: Vector.<SpriteExtracted> = new Vector.<SpriteExtracted>();
			for each (sprite in spriteDict) {
				finalSprites.push(sprite);
			}
			finalSprites.sort(function (sprite1:SpriteExtracted, sprite2:SpriteExtracted): int {
									var val1: int = (sprite1.rect.y - 1) * ssWidth + sprite1.rect.x;
									var val2: int = (sprite2.rect.y - 1) * ssWidth + sprite2.rect.x;
									return val1 < val2 ? -1 : 1;
								});
			Logger.log("Num of sprites "+ finalSprites.length);
			spriteSheet.sprites = finalSprites;
			return finalSprites;		
		}
	}
	
}





