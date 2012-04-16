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
  
	public class MsgBuffer extends Sprite {
			private var w						:uint = 120;
			private var h						:uint = 12;
			private var s						:int = 0;
			private var dx					:uint = 0;

			private	var pb					:Shape;

			private var mtx					:Matrix;
			private var mtxnull			:Matrix;
		
			private	var lStatusText	:TextField;
			private var t						:Timer;
			
			public function MsgBuffer () {
				t = new Timer(70, 1);
				t.addEventListener(TimerEvent.TIMER, RedrawProgressBar); 

				pb = new Shape;
				mtx = new Matrix();
				mtxnull = new Matrix();
				lStatusText = new TextField();

				var ftLabel:TextFormat = new TextFormat();
				ftLabel.font = "Arial";
		    ftLabel.size = 10;
		    ftLabel.bold = 0;
				ftLabel.color = 0xdb9f0f;

				lStatusText.defaultTextFormat = ftLabel;
		    lStatusText.setTextFormat( ftLabel );
				lStatusText.autoSize = TextFieldAutoSize.RIGHT;
				lStatusText.text = "Буферизация";
				lStatusText.selectable = false;
				lStatusText.x = (Math.round(w / 2) - Math.round(lStatusText.width / 2)) + 1;
				lStatusText.y = -3;

			  mtx.createGradientBox(10, h, Math.PI / 4, 0, 0);
		  	mtxnull.createGradientBox(10, h, Math.PI / 4, 0, 0);

		  	RedrawProgressBar();
		  	
				addChild(pb);			
				addChild(lStatusText);
			}

			public function Show () : void 
			{
				if (!s) {
					s = 1;
					t.start();
				}
			}

			public function Hide () : void
			{
				if (s) {
					s = 0;
				}
			}

    public function RedrawProgressBar(event:TimerEvent = null):void 
    {
			pb.graphics.clear();
			pb.graphics.lineStyle(2, 0xFFFFFF);
			dx++;
			if (dx > 18) { mtx = null; mtx = mtxnull.clone(); dx = 0; }
			mtx.translate(3, 0);
			//pb.graphics.beginGradientFill(GradientType.LINEAR, [0xfe8621, 0xfeb64d], [100, 100], [40, 180], mtx, SpreadMethod.REFLECT);
			pb.graphics.beginGradientFill(GradientType.LINEAR, [0x0018ff, 0x355380], [100, 100], [40, 180], mtx, SpreadMethod.REFLECT);
			pb.graphics.drawRoundRect(0, 0, w, h, 4);
			pb.graphics.endFill();
			
			t.reset();
			if (s) { t.start(); }
    }			
	}
}
