package images
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import utils.Logger;

	public class ImageProvider extends EventDispatcher
	{
		private const PNG: String = "png";
		private var browseFiles:File;
		private var imageFiles:Vector.<File>;
		private var loader:Loader;

		public function ImageProvider()
		{
		}
		
		public function loadFile(): void {
			var params: CLParams = CLParams.getInstance();
			if (params.clMode) {
				var files: Vector.<File> = new Vector.<File>();
				files.push(new File(params.getParam(CLParams.SRC_FILE)));
				loadFiles(files);
			} else {
				browseFiles = new File();
				browseFiles.addEventListener(Event.SELECT, onFileSelected);
				browseFiles.browseForOpen("Choose a sprite sheet");
			}
		}

		public function loadMultiple(): void {
			browseFiles = new File();
			browseFiles.addEventListener(FileListEvent.SELECT_MULTIPLE, onMultipleSelected);
			browseFiles.browseForOpenMultiple("Choose a files");
		}

		private function onMultipleSelected(event: FileListEvent): void {
			loadFiles(Vector.<File>(event.files));
		}

		public function loadFolder(): void {
			var params: CLParams = CLParams.getInstance();
			if (params.clMode) {
				var folder: File = new File(params.getParam(CLParams.SRC_FOLDER));
				loadFiles(Vector.<File>(folder.getDirectoryListing()));
			} else {
				 browseFiles = new File();
				 browseFiles.addEventListener(Event.SELECT, onFolderSelected);
				 browseFiles.browseForDirectory("Choose a directory");
			}
		}


		private function onFileSelected(event: Event): void {
			var files: Vector.<File> = new Vector.<File>();
			files.push(File(event.target));
			loadFiles(files);
		}

		private function filterPngs(files: Vector.<File>): Vector.<File> {
			var file: File;
			var extension: String;
			var dotSeparatedParts: Array;
			for (var i: int = files.length - 1; i > -1; --i) {
				file = files[i];
				dotSeparatedParts = file.url.split(".");
				extension = dotSeparatedParts[dotSeparatedParts.length - 1];
				if (extension != PNG) {
					files.splice(i, 1);
				}
			}
			return files;
		}
		
		private function onFolderSelected(event:Event):void
		{
			loadFiles(Vector.<File>(event.target.getDirectoryListing()));
		}

		private function loadFiles(files: Vector.<File>): void {
			files = filterPngs(files);
			imageFiles = files;
			if (imageFiles.length > 0) {
				var nextFile: File = imageFiles.shift();
				load(nextFile.url);
			}
		}

		private function load(spriteSheet:String):void
		{
			Logger.log("--------------------------------- ");
			Logger.log("Loading started " + spriteSheet);
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadCompleted, false, 0 ,true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadFailed, false, 0 ,true);
			loader.load(new URLRequest(spriteSheet));
		}
		
		protected function onLoadFailed(event: IOErrorEvent):void
		{
			Logger.error("Loading failed! ");
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadCompleted);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadFailed);
			//throw new Error("Loading image failed!");
			if (imageFiles.length > 0){
				var nextFile: File = imageFiles.shift();
				load(nextFile.url);
			} else {
				dispatchEvent(new ImageEvent(ImageEvent.LAST_IMAGE_FAILED,null));
			}
		}
		
		protected function onLoadCompleted(event:Event):void
		{
			Logger.log("Loading completed!");
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadCompleted);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadFailed);
			
			var image:Image = new Image();
			var bmpLocal: Bitmap = Bitmap(loader.content);
			image.bmpData = bmpLocal.bitmapData;
			var pathDecomposed: Array = loader.contentLoaderInfo.url.split("/");
			image.name = pathDecomposed[pathDecomposed.length - 1].split(".")[0];
			var len: int = imageFiles.length;
			if (len == 0) {
				dispatchEvent(new ImageEvent(ImageEvent.LAST_IMAGE_LOADED,image));
			}
			dispatchEvent(new ImageEvent(ImageEvent.IMAGE_LOADED,image));
			
			if (len > 0){
				var nextFile: File = imageFiles.shift();
				load(nextFile.url);
			}
		}
	}
}