package
{
	import com.adobe.images.PNGEncoder;
	import com.adobe.protocols.dict.Dict;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.ReturnKeyLabel;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	import spritetools.AnimationDeltaConverter;
	import spritetools.SpriteExporter;
	import spritetools.SpriteExtractor;
	import spritetools.SpriteHighlighter;

	import images.Image;

	import utils.Logger;
	import images.Image;
	import images.ImageEvent;
	import images.ImageProvider;
	
	[SWF(height="1024", width="1024")]
	public class ExtractSprites extends Sprite
	{
		private var bmp: Bitmap;		
		
		private var spriteSheetProvider: ImageProvider;
		private var spriteExtractor: SpriteExtractor;
		private var spriteExporter: SpriteExporter;
		private var spriteHighlighter: SpriteHighlighter;
		private var _animationDeltaConverter: AnimationDeltaConverter;
		private var lastSpriteSheetLoaded: Boolean;
		private var now: Number;
		private var numImagesProcessed: int;
		private var isAnimationConversion: Boolean = false;
		//1. command line;
		//2. ui
		//3. folders
	
		public function ExtractSprites()
		{

			spriteSheetProvider = new ImageProvider();
			spriteExporter = new SpriteExporter();
			spriteExtractor = new SpriteExtractor();
			spriteHighlighter = new SpriteHighlighter();
			_animationDeltaConverter = new AnimationDeltaConverter();
			Logger.init();
			
			spriteSheetProvider.addEventListener(ImageEvent.IMAGE_LOADED, onSpriteSheetLoaded);
			spriteSheetProvider.addEventListener(ImageEvent.LAST_IMAGE_LOADED, onLastSpriteSheetLoaded);
			spriteSheetProvider.addEventListener(ImageEvent.LAST_IMAGE_FAILED, onLastSpriteSheetFailed);
			bmp = new Bitmap();
			bmp.scaleX = bmp.scaleY = 0.5;
			spriteHighlighter.scaleX = spriteHighlighter.scaleY = bmp.scaleX;
			addChild(bmp);
			addChild(spriteHighlighter);
			addChild(Logger.console);


			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onAppInvoked);
		}

		private function onLastSpriteSheetFailed(event: ImageEvent): void {
			generateLogs();
		}

		private function onLastSpriteSheetLoaded(event: ImageEvent): void {
			lastSpriteSheetLoaded = true;
			if (isAnimationConversion) {
				var compressedSprites: Vector.<Image> = _animationDeltaConverter.convert();
				var len: int = compressedSprites.length;
				for (var i: int = 0; i < len; ++i) {
					spriteExporter.exportSprites(compressedSprites[i]);
				}

			}
		}

		private function onSpriteSheetLoaded(event:ImageEvent):void
		{
			if (isAnimationConversion) {
				_animationDeltaConverter.addSprite(event.image);
			} else {
				startExtraction(event.image);
			}
		}
		
		private function startExtraction(spriteSheet: Image): void {
			bmp.bitmapData && bmp.bitmapData.dispose();
			bmp.bitmapData = spriteSheet.bmpData;			
			spriteExtractor.extractSprites(spriteSheet);
			//if (!CLParams.getInstance().clMode) {
				spriteHighlighter.highlightSprites(spriteSheet.sprites);
			//}
			spriteExporter.exportSprites(spriteSheet);
			numImagesProcessed ++;
			if (lastSpriteSheetLoaded) {
				shutDownGracefully();
			}
		}

		private function shutDownGracefully(): void {
			generateLogs();
			//CLParams.getInstance().clMode && NativeApplication.nativeApplication.exit();
		}

		private function generateLogs(): void {
			var totalTime: Number = getTimer() - now;
			Logger.log("--------------------------------- ");
			Logger.log("Total num of PNG images processed: " + numImagesProcessed);
			Logger.log("Total time: " + totalTime + "ms.");


			createLogFile("_normalLog.txt", Logger.normalLog);
			createLogFile("_errorLog.txt", Logger.errorLog);
			createLogFile("_warningLog.txt", Logger.warningLog);
		}

		private function createLogFile(fileName:String, logText: String): void {
			var ba: ByteArray = new ByteArray();
			ba.writeUTFBytes(logText);
			var s: String = File.separator;
			var destinationPath: String = CLParams.getInstance().getParam(CLParams.DEST_FOLDER);
			var startSeparator: String = destinationPath.charAt(destinationPath.length - 1) == s ? "" : s;
			var filePath: String = startSeparator + destinationPath + s + fileName;

			var file: File = new File(filePath);
			var fileStream: FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(ba);
			fileStream.close();
		}

		private function onAppInvoked(event:InvokeEvent):void
		{
			var params: CLParams = CLParams.getInstance();
			params.apply(event.arguments);
			if (params.getParam(CLParams.SRC_FOLDER)) {
				now = getTimer();
				spriteSheetProvider.loadFolder();
			} else if (params.getParam(CLParams.SRC_FILE)) {
				now = getTimer();
				spriteSheetProvider.loadFile();
			} else if (!params.clMode) {
				now = getTimer();
				//spriteSheetProvider.loadFolder();
				spriteSheetProvider.loadFile();
				//spriteSheetProvider.loadMultiple();
			}
		}		
	}
}
