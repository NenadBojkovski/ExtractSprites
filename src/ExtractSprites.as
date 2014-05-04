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
	
	[SWF(height="2048", width="2048")]
	public class ExtractSprites extends Sprite
	{
		private var bmp: Bitmap;		
		
		private var params: CLParams;
		
		private var spriteSheetProvider: SpriteSheetProvider;
		private var spriteExtractor: SpriteExtractor;
		private var spriteExporter: SpriteExporter;
		private var spriteHighlighter: SpriteHighlighter;
		
		//1. command line;
		//2. ui
		//3. folders
	
		public function ExtractSprites()
		{
			//params = new CLParams();
			spriteSheetProvider = new SpriteSheetProvider();
			spriteExporter = new SpriteExporter();
			spriteExtractor = new SpriteExtractor();
			spriteHighlighter = new SpriteHighlighter();
			Logger.init();
			
			spriteSheetProvider.addEventListener(SpriteSheetEvent.SPRITE_SHEET_AVAILABLE, onSpriteSheetAvailable);
			
			addChild(bmp = new Bitmap());
			addChild(spriteHighlighter);
			addChild(Logger.console);
			
		
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onAppInvoked);
		}
		
		protected function onSpriteSheetAvailable(event:SpriteSheetEvent):void
		{
			startExtraction(event.spriteSheet)
			
		}
		
		private function startExtraction(spriteSheet: SpriteSheet): void {
			bmp.bitmapData && bmp.bitmapData.dispose();
			bmp.bitmapData = spriteSheet.bmpData;			
			spriteExtractor.extractSprites(spriteSheet);
			spriteHighlighter.highlightSprites(spriteSheet.sprites);
			spriteExporter.exportSprites(spriteSheet);
		}
		
		protected function onAppInvoked(event:InvokeEvent):void
		{
			//spriteSheetProvider.loadDefault();
			spriteSheetProvider.loadSpriteFolder();
			/*var arguments: Array = event.arguments;
			arguments[0] = "spriteSheet=E:/Development/ExtractSprites/assets/sprites_2.png";
			var len: int = arguments.length;
			if (len > 0){
				for (var i: int = 0; i < len; ++i){
					var paramPair: Array = String(arguments[i]).split("=");
					params.setParam(paramPair[0], paramPair[1]);
				}
				extract(params.getParam(CLParams.SPRITE_SHEET));
			} else { 
				extract(CLParams.DEFAULT);
			}*/
		}		
	}
}
