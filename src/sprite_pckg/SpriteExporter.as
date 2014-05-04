package sprite_pckg
{
	import com.adobe.images.PNGEncoder;
	
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import spritesheet_pckg.SpriteSheet;

	import utils.Logger;

	public class SpriteExporter
	{
		public function SpriteExporter()
		{
		}
		
		public function exportSprites(spriteSheet: SpriteSheet): void
		{
			var params: CLParams = CLParams.getInstance();
			var exportingSprites: Vector.<SpriteExtracted> = spriteSheet.sprites;
			var bmpData: BitmapData = spriteSheet.bmpData;
			var configFile: String = "";
			var fileName: String;
			var spriteName: String = spriteSheet.name;
			var s: String = File.separator;
			var destinationPath: String = params.getParam(CLParams.DEST_FOLDER);
			var startSeparator: String = destinationPath.charAt(destinationPath.length - 1) == s ? "" : s;
			var filePrefix: String = startSeparator + destinationPath + s + spriteName + s;
			Logger.log("Destination folder: "+filePrefix);
			var ba:ByteArray;
			var zeroPoint: Point = new Point();
			var rect: Rectangle;
			var pngSource:BitmapData;
			var file: File;
			var fileStream: FileStream;
			var len: int = exportingSprites.length;
			for (var i: int = 0; i < len; ++i) { 
				rect = exportingSprites[i].rect;
				pngSource = new BitmapData (rect.width, rect.height, true, 0x00000000);
				pngSource.copyPixels(bmpData, rect, zeroPoint);
				ba = PNGEncoder.encode(pngSource);
				fileName = spriteName + "_" + i + ".png";
				file = new File(filePrefix + fileName);
				fileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeBytes(ba);
				fileStream.close();	
				pngSource.dispose();
				configFile += formatConfigEntry(fileName, i, rect);
			}
			ba = new ByteArray();
			ba.writeUTFBytes(configFile);
			fileName = spriteName + ".txt";
			file = new File(filePrefix + fileName);
			fileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(ba);
			fileStream.close();	
		}
		
		private function formatConfigEntry(fileName:String, index: int, rect:Rectangle):String {
			return index + " " + fileName + " " + rect.left + " " + rect.top + " " + rect.width + " " + rect.height + "\n";
		}		
	}
}