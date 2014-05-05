package sprite_pckg {
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	import spritesheet_pckg.SpriteSheet;

	public class AnimationCompressor {
		private var spritesToCompress: Vector.<SpriteSheet>;
		public function AnimationCompressor() {
			spritesToCompress = new Vector.<SpriteSheet>();
		}

		public function addSprite(spriteSheet: SpriteSheet): void {
			spritesToCompress.push(spriteSheet);
		}

		public function compress(): Vector.<SpriteSheet> {
			var compressedSprites: Vector.<SpriteSheet> = new Vector.<SpriteSheet>();
			var len: int = spritesToCompress.length;
			var sprite: SpriteSheet;
			for (var i: int = 1; i < len; ++i) {
				sprite = findDelta(spritesToCompress[i-1], spritesToCompress[i]);
				compressedSprites.push(sprite);
			}
			return compressedSprites;
		}

		private function findDelta(spriteSheet1: SpriteSheet, spriteSheet2: SpriteSheet): SpriteSheet {
			var sprite: SpriteExtracted;
			var bmpData1: BitmapData = spriteSheet1.bmpData;
			var bmpData2: BitmapData = spriteSheet2.bmpData;
			if (!bmpData1 || !bmpData2 || bmpData1.width != bmpData2.width || bmpData1.height != bmpData2.height) {
				sprite = new SpriteExtracted();
				sprite.rect = bmpData2.rect;
				spriteSheet2.sprites = new Vector.<SpriteExtracted>();
				spriteSheet2.sprites.push(sprite);
				return spriteSheet2;
			}

			var width: int = bmpData2.width;
			var height: int = bmpData2.height;
			var bmpDataCompressed: BitmapData = new BitmapData(width, height, true, 0x00000000);
			var pixelValue: uint;
			for (var y: int = 0; y < height; ++y) {
				for (var x: int = 0; x < width; ++x) {
					pixelValue = bmpData2.getPixel32(x, y);
					if (pixelValue != bmpData1.getPixel32(x,y)) {
						bmpDataCompressed.setPixel32(x, y, pixelValue);
					}
				}
			}
			var compressedSprite: SpriteSheet = new SpriteSheet();
			compressedSprite.bmpData = bmpDataCompressed;
			sprite = new SpriteExtracted();
			sprite.rect = bmpDataCompressed.rect;
			compressedSprite.sprites = new Vector.<SpriteExtracted>();
			compressedSprite.sprites.push(sprite);
			compressedSprite.name = spriteSheet2.name;

			return compressedSprite;
		}

	}

}
