package {
	import flash.display.Sprite;
 	import flash.text.TextField;
  import flash.text.TextFieldType;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  	
	public class Watcher extends Sprite {
		private var lWatcher				:TextField;
		private var lWatcherCount		:TextField;
		private var c								:int = 0;
		
		public function Watcher () {
			var f:TextFormat = new TextFormat();
			lWatcher = new TextField();
			lWatcherCount = new TextField();
						
			f.font = "Arial";
      f.size = 12;
      f.bold = 1;
      
			lWatcher.defaultTextFormat = f;
      lWatcher.setTextFormat( f );
			lWatcher.text = "зрителей";
			lWatcher.autoSize = TextFieldAutoSize.LEFT;
			lWatcher.textColor = 0x545454;
			lWatcher.selectable = false;
			lWatcher.x = 200 - lWatcher.width;

			
			lWatcherCount.defaultTextFormat = f;
      lWatcherCount.setTextFormat( f );
			lWatcherCount.text = c.toString();
			lWatcherCount.autoSize = TextFieldAutoSize.RIGHT;
			lWatcherCount.textColor = 0xdc0015;
			lWatcherCount.selectable = false;
			lWatcherCount.x = 200 - lWatcher.width - lWatcherCount.width - 2;

			addChild(lWatcher);
			addChild(lWatcherCount);			
		}
		public function set count( value: int ) :void
    {
    	if (c != value) {
				c = value;
				lWatcherCount.text = c.toString();
			}
    }
	}
}
