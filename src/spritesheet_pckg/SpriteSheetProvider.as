package spritesheet_pckg
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import utils.Logger;

	public class SpriteSheetProvider extends EventDispatcher
	{
		//[Embed(source="../assets/SpriteSheet4.png")]
		//[Embed(source="../assets/SpriteSheet1.png")]
		//[Embed(source="../assets/SpriteSheet2.png")]
		//[Embed(source="../assets/SpriteSheet3.png")]
		//[Embed(source="../assets/sprites_2.png")]
		private var SpriteSheetClass:Class;
		private var defaultName: String = "SpriteSheet3";
		private var browseFiles:File;
		private var spriteSheetFiles:Vector.<File>;
		private var loader:Loader;
		
		public function SpriteSheetProvider()
		{
		}
		
		public function loadDefault(): void {
			var spriteSheet: SpriteSheet = new SpriteSheet();
			var bmpLocal: Bitmap = new SpriteSheetClass();
			spriteSheet.bmpData = bmpLocal.bitmapData;
			spriteSheet.name = defaultName;
			dispatchEvent(new SpriteSheetEvent(SpriteSheetEvent.SPRITE_SHEET_AVAILABLE,spriteSheet));
		}
		
		public function loadSpriteFolder(): void {
			browseFiles = new File();
			browseFiles.addEventListener(Event.SELECT, onFolderSelected);
			browseFiles.browseForDirectory("Choose a directory");
		}
		
		protected function onFolderSelected(event:Event):void
		{
			spriteSheetFiles = Vector.<File>(event.target.getDirectoryListing());
			var nextFile: File = spriteSheetFiles.shift();
			load(nextFile.url);
		}
		
		private function load(spriteSheet:String):void
		{
			Logger.log("Loading started " + spriteSheet);
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadCompleted, false, 0 ,true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadFailed, false, 0 ,true);
			loader.load(new URLRequest(spriteSheet));
					
			
		}
		
		protected function onLoadFailed(event:Event):void
		{
			Logger.log("Loading failed!");
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadCompleted);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadFailed);
			//throw new Error("Loading image failed!");
			if (spriteSheetFiles.length > 0){
				var nextFile: File = spriteSheetFiles.shift();
				load(nextFile.url);
			}
		}
		
		protected function onLoadCompleted(event:Event):void
		{
			Logger.log("Loading completed!");
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadCompleted);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadFailed);
			
			var spriteSheet:SpriteSheet = new SpriteSheet();
			var bmpLocal: Bitmap = Bitmap(loader.content);
			spriteSheet.bmpData = bmpLocal.bitmapData;
			var pathDecomposed: Array = loader.contentLoaderInfo.url.split("/");
			spriteSheet.name = pathDecomposed[pathDecomposed.length - 1].split(".")[0];
			dispatchEvent(new SpriteSheetEvent(SpriteSheetEvent.SPRITE_SHEET_AVAILABLE,spriteSheet));
			
			if (spriteSheetFiles.length > 0){
				var nextFile: File = spriteSheetFiles.shift();
				load(nextFile.url);
			}
		}
	}
}