package spritetools {
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	import images.Image;

	public class AnimationDeltaConverter {
		private var spritesToConvert: Vector.<Image>;
		public function AnimationDeltaConverter() {
			spritesToConvert = new Vector.<Image>();
		}

		public function addSprite(image: Image): void {
			spritesToConvert.push(image);
		}

		public function convert(): Vector.<Image> {
			spritesToConvert.sort(function (image1: Image, image2: Image): int {
				return image1.name < image2.name ? -1 : 1;
			});
			var compressedSprites: Vector.<Image> = new Vector.<Image>();
			var len: int = spritesToConvert.length;
			var sprite: Image;
			for (var i: int = 1; i < len; ++i) {
				sprite = findDelta(spritesToConvert[i-1], spritesToConvert[i]);
				compressedSprites.push(sprite);
			}
			return compressedSprites;
		}

		private function findDelta(image1: Image, image2: Image): Image {
			var sprite: SpriteExtracted;
			var bmpData1: BitmapData = image1.bmpData;
			var bmpData2: BitmapData = image2.bmpData;
			if (!bmpData1 || !bmpData2 || bmpData1.width != bmpData2.width || bmpData1.height != bmpData2.height) {
				sprite = new SpriteExtracted();
				sprite.rect = bmpData2.rect;
				image2.sprites = new Vector.<SpriteExtracted>();
				image2.sprites.push(sprite);
				return image2;
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
			var compressedSprite: Image = new Image();
			compressedSprite.bmpData = bmpDataCompressed;
			sprite = new SpriteExtracted();
			sprite.rect = bmpDataCompressed.rect;
			compressedSprite.sprites = new Vector.<SpriteExtracted>();
			compressedSprite.sprites.push(sprite);
			compressedSprite.name = image2.name;

			return compressedSprite;
		}

	}

}
