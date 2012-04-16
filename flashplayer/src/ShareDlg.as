package {
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.CapsStyle;
  import flash.display.LineScaleMode;
 	import flash.display.StageScaleMode;
 	import flash.text.TextField;
  import flash.text.TextFieldType;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.LineScaleMode;
	import flash.display.SpreadMethod;
	import flash.events.TimerEvent; 
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.MouseEvent;

	  
	public class ShareDlg extends Sprite {
	  private var lx           :uint = 0;
	  private var ly           :uint = 0;
		private var w						:uint = 460;
		private var h						:uint = 350;
	  private	var bg					:Shape;

		private	var labelURL    :TextField;
		private	var textURL     :TextField;
		private	var labelCode   :TextField;
		private	var textCode    :TextField;
		private	var labelClose  :TextField;
	  
		public function ShareDlg (sw : uint, sh : uint) {
      bg = new Shape;
      labelURL = new TextField();
      textURL = new TextField();
      labelCode = new TextField();
      textCode = new TextField();
      labelClose = new TextField();

      lx = (sw - w) / 2;
      ly = (sh - h) / 2;
		
      bg.graphics.lineStyle(1, 0xffffff);
			bg.graphics.beginFill(0x000000, 0.8);
			bg.graphics.drawRoundRect(lx, ly, w, h, 8, 8);
			bg.graphics.endFill();


			var ftlabel:TextFormat = new TextFormat();
			ftlabel.font = "Arial";
      ftlabel.size = 16;
      //ftlabel.bold = 1;
			ftlabel.color = 0xffffff;		

			var ftbox:TextFormat = new TextFormat();
			ftbox.align = TextFormatAlign.LEFT;
			ftbox.font = "Arial";
      ftbox.size = 14;
      ftbox.italic = 1;
			ftbox.color = 0xffffff;		

			var ftButton:TextFormat = new TextFormat();
			ftButton.font = "Arial";
      ftButton.size = 12;
      ftButton.bold = 1;
			ftButton.color = 0xcccccc;		
			
			labelURL.defaultTextFormat = ftlabel;
      labelURL.setTextFormat( ftlabel );
			labelURL.text = "Постоянная ссылка:";
			labelURL.autoSize = TextFieldAutoSize.LEFT;
			labelURL.selectable = false;
			labelURL.x = lx + 15;
			labelURL.y = ly + 20;

			textURL.defaultTextFormat = ftbox;
      textURL.setTextFormat( ftbox );
			textURL.text = "http://kprf.tv/online/";
			textURL.selectable = true;
			textURL.background = true;
			textURL.backgroundColor = 0xbbbbbb;
			textURL.border = true;
			textURL.borderColor = 0xffffff;
			textURL.x = lx + 15;
			textURL.y = ly + 42;
			textURL.width = w - 30;
			textURL.height = 22;
			textURL.addEventListener(MouseEvent.CLICK, clickHandler);
			
			labelCode.defaultTextFormat = ftlabel;
      labelCode.setTextFormat( ftlabel );
			labelCode.text = "HTML-код для добавления на сайт:";
			labelCode.autoSize = TextFieldAutoSize.LEFT;
			labelCode.selectable = false;
			labelCode.x = lx + 15;
			labelCode.y = ly + 80;

			textCode.defaultTextFormat = ftbox;
      textCode.setTextFormat( ftbox );
			textCode.text = "<object width=\"862\" height=\"570\"><param name=\"movie\" value=\"http://kprf.tv/misc/kprftvlive.swf\"></param><param name=\"allowFullScreen\" value=\"true\"></param><param name=\"allowscriptaccess\" value=\"always\"></param><embed src=\"http://kprf.tv/misc/kprftvlive.swf\" type=\"application/x-shockwave-flash\" width=\"862\" height=\"570\" allowscriptaccess=\"always\" allowfullscreen=\"true\"></embed></object>";
			textCode.selectable = true;
			textCode.background = true;
			textCode.backgroundColor = 0xbbbbbb;
			textCode.border = true;
			textCode.borderColor = 0xffffff;
			textCode.wordWrap = true;
      textCode.multiline = true;
			textCode.x = lx + 15;
			textCode.y = ly + 102;
		  textCode.width = w - 30;
			textCode.height = 200;
			textCode.addEventListener(MouseEvent.CLICK, clickHandler);

			labelClose.defaultTextFormat = ftButton;
      labelClose.setTextFormat( ftButton );
			labelClose.htmlText = "<a href='event:null'>Закрыть</a>";
			labelClose.autoSize = TextFieldAutoSize.RIGHT;
			labelClose.selectable = false;
			labelClose.x = lx + w - 66;
			labelClose.y = ly + h - 40;
			labelClose.addEventListener(MouseEvent.CLICK, onClose);
								
			addChild(bg);
			addChild(labelURL);
			addChild(textURL);
			addChild(labelCode);
			addChild(textCode);
			addChild(labelClose);			
	  }

	  public function onClose( e:Event ) : void {
				dispatchEvent( new Event( "CloseShare" ) );
		}

		private function clickHandler(event:MouseEvent):void {
        event.target.setSelection(0, 1000);
    }


	}
}
