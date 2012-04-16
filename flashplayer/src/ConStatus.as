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
  
	public class ConStatus extends Sprite {
		private var w						:uint = 218;
		private var h						:uint = 30;
		private var dx					:uint = 0;
		
		private var cstatus			:uint = 0;
		private	var bg					:Shape;

		private var pbstarted		:uint = 0;
		private	var pb					:Shape;
		private var mtx					:Matrix;
		private var mtxnull			:Matrix;
				
		private	var ftLabel			:TextFormat;
		private	var ftValue			:TextFormat;
		
		private	var lStatus			:TextField;
		private	var lStatusText	:TextField;

		private var t						:Timer;
		
		public function ConStatus () {
			t = new Timer(70, 0);
			t.addEventListener(TimerEvent.TIMER, RedrawProgressBar); 
			
			bg = new Shape;
			pb = new Shape;
			mtx = new Matrix();
			mtxnull = new Matrix();
			
			bg.graphics.lineStyle();
			bg.graphics.beginFill(0x000000, 0.3);
			bg.graphics.drawRect(0, 0, w, h);
			bg.graphics.endFill();

			ftLabel = new TextFormat();
			ftLabel.font = "Arial";
      ftLabel.size = 12;
      ftLabel.bold = 1;
			ftLabel.color = 0xffffff;

			ftValue = new TextFormat();
			ftValue.font = "Arial";
      ftValue.size = 12;
      ftValue.bold = 1;
			ftValue.color = 0xf4eb55;


			lStatus = new TextField();
			lStatusText = new TextField();

			lStatus.defaultTextFormat = ftLabel;
      lStatus.setTextFormat( ftLabel );
			lStatus.text = "Состояние канала:";
			lStatus.autoSize = TextFieldAutoSize.LEFT;
			lStatus.selectable = false;
			lStatus.x = 5;
			lStatus.y = 5;

			lStatusText.defaultTextFormat = ftValue;
      lStatusText.setTextFormat( ftValue );
			updateL();
			lStatusText.autoSize = TextFieldAutoSize.NONE;
			lStatusText.selectable = false;
			lStatusText.x = lStatus.x + lStatus.width + 6;
			lStatusText.y = 5;
			lStatusText.width = w - lStatus.width - 15;
			lStatusText.height = 18;
							
			addChild(bg);
			addChild(lStatus);
			addChild(lStatusText);


    	mtx.createGradientBox(10, h, Math.PI / 4, 0, 0);
    	mtxnull.createGradientBox(10, h, Math.PI / 4, 0, 0);
    	RedrawProgressBar();
		}
		public function set status( value: uint ) : void
    {
			cstatus = value;
			updateL();
    }

		public function get status() : uint
    {
			return cstatus;
    }
    
   	private function updateL( ) : void
    {
			switch (cstatus) {
			case 0:
				HideProgressBar();
				lStatusText.text = "Отключено";
				lStatusText.textColor = 0xf4eb55;
				break;
			case 1:
				HideProgressBar();
				lStatusText.text = "Подключено";
				lStatusText.textColor = 0x30ff00;
				break;
			case 2:
				lStatusText.text = "Подключение";
				lStatusText.textColor = 0xf4eb55;
				ShowProgressBar();
				break;
			}
    }

    public function RedrawProgressBar(event:TimerEvent = null):void 
    {
			pb.graphics.clear();
			pb.graphics.lineStyle(2, 0xFFFFFF);
			dx++;
			if (dx > 18) { mtx = null; mtx = mtxnull.clone(); dx = 0; }
			mtx.translate(3, 0);
			//pb.graphics.beginGradientFill(GradientType.LINEAR, [0x0018ff, 0x355380], [100, 100], [40, 180], mtx, SpreadMethod.REFLECT);
			pb.graphics.beginGradientFill(GradientType.LINEAR, [0xfe8621, 0xfeb64d], [100, 100], [40, 180], mtx, SpreadMethod.REFLECT);
			pb.graphics.drawRoundRect(5, h + 6, w - 10, 12, 4);
			pb.graphics.endFill();
    }
    
    private function ShowProgressBar() : void
    {
    	if (!pbstarted) {
				pbstarted = 1;
				addChild(pb);
				t.start();
			}
    }
    
    private function HideProgressBar() : void
    {
    	if (pbstarted) {
    		pbstarted = 0;
    		t.stop();
				removeChild(pb);
			}
    }
    
	}

}
