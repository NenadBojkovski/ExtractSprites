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
	import sprite_pckg.SpriteExporter;
	import sprite_pckg.SpriteExtractor;
	import sprite_pckg.SpriteHighlighter;
	import utils.Logger;
	import spritesheet_pckg.SpriteSheet;
	import spritesheet_pckg.SpriteSheetEvent;
	import spritesheet_pckg.SpriteSheetProvider;
	
	[SWF(height="1024", width="1024")]
	public class ExtractSprites extends Sprite
	{
		private var bmp: Bitmap;		
		
		private var spriteSheetProvider: SpriteSheetProvider;
		private var spriteExtractor: SpriteExtractor;
		private var spriteExporter: SpriteExporter;
		private var spriteHighlighter: SpriteHighlighter;
		private var lastSpriteSheetLoaded: Boolean;
		private var now: Number;
		private var numImagesProcessed: int;
		//1. command line;
		//2. ui
		//3. folders
	
		public function ExtractSprites()
		{

			spriteSheetProvider = new SpriteSheetProvider();
			spriteExporter = new SpriteExporter();
			spriteExtractor = new SpriteExtractor();
			spriteHighlighter = new SpriteHighlighter();
			Logger.init();
			
			spriteSheetProvider.addEventListener(SpriteSheetEvent.SPRITE_SHEET_LOADED, onSpriteSheetLoaded);
			spriteSheetProvider.addEventListener(SpriteSheetEvent.LAST_SPRITE_SHEET_LOADED, onLastSpriteSheetLoaded);
			spriteSheetProvider.addEventListener(SpriteSheetEvent.LAST_SPRITE_SHEET_FAILED, onLastSpriteSheetFailed);
			bmp = new Bitmap();
			bmp.scaleX = bmp.scaleY = 0.5;
			spriteHighlighter.scaleX = spriteHighlighter.scaleY = bmp.scaleX;
			addChild(bmp);
			addChild(spriteHighlighter);
			addChild(Logger.console);
			
		
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onAppInvoked);
		}

		private function onLastSpriteSheetFailed(event: SpriteSheetEvent): void {
			generateLogs();
		}

		private function onLastSpriteSheetLoaded(event: SpriteSheetEvent): void {
			lastSpriteSheetLoaded = true;
		}

		private function onSpriteSheetLoaded(event:SpriteSheetEvent):void
		{
			startExtraction(event.spriteSheet)
			
		}
		
		private function startExtraction(spriteSheet: SpriteSheet): void {
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
			}
		}		
	}
}
