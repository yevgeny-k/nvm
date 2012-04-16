package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.text.TextField;
  import flash.text.TextFieldType;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.CapsStyle;
  import flash.display.LineScaleMode;
 	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.net.Responder;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import com.adobe.crypto.*;
	

	public class kprftvliveconsole extends Sprite {
		private	var mfWidth				:Number = 800;
		private	var mfHeight			:Number = 350;
		
		private var t							:Timer;

		private var nc						:NetConnection = null;
		private var serverName		:String = "rtmp://live1.kprfmedia.com:80/kprftv";
		private var streamName		:String = "mainstream";
		private var ipgeturl			:String = "http://kprf.tv/misc/ipget.php";
		private var ip						:String = "";	
		
		private var cnst					:ConStatus;

		private var conn					:uint = 0;
		private var tst						:uint = 2;

		private	var bg						:Shape;
		private var l1						:TextField;
		private var l2						:TextField;
		private var ebDate				:TextField;
		private var l3						:TextField;
		private var ebTitle				:TextField;
		private var l4						:TextField;
			
		private	var btON					:StandardButton;
		private	var btOFF					:StandardButton;
		private	var btpic1				:StandardButton;
		private	var btpic2				:StandardButton;
		private	var btpic3				:StandardButton;
		private	var btSend				:StandardButton;

		private var piccommon			:String = "http://kprf.tv/misc/broadcast/common.jpg";
		private var picduma				:String = "http://kprf.tv/misc/broadcast/duma.jpg";
		private var pic						:String = "";
		private var picinx				:int = 5;
		
		private var	sp						:String = "hjdshJJHDSYEWk;__+==dwewe3";
		private var hash					:String = "";
			
		public function kprftvliveconsole () {
			stage.scaleMode = StageScaleMode.NO_SCALE; 
			stage.align = StageAlign.TOP_LEFT;

			Security.allowDomain( "*" );

			bg = new Shape;
			bg.graphics.lineStyle();
			bg.graphics.beginFill(0xcccccc); 
			bg.graphics.drawRect(0, 0, mfWidth, mfHeight);
			
			cnst = new ConStatus();
			cnst.x = 0;
			cnst.y = 0;


			var f:TextFormat = new TextFormat();
			f.font = "Arial";
      f.size = 15;
      f.bold = 1;

			var fi:TextFormat = new TextFormat();
			fi.font = "Arial";
      fi.size = 15;
      fi.bold = 0;
            
			l1 = new TextField();
			l1.defaultTextFormat = f;
      l1.setTextFormat( f );
			l1.text = "Трансляция";
			l1.autoSize = TextFieldAutoSize.LEFT;
			l1.textColor = 0x484848;
			l1.selectable = false;
			l1.y = cnst.height + 40;

			
			btON = new StandardButton( "Вкл.", 120, l1.y - 4, StandardButton.GREEN_BUTTON);
			btOFF = new StandardButton( "Выкл.", btON.x + l1.width, l1.y - 4, StandardButton.GREY_BUTTON);
			btON.addEventListener(MouseEvent.CLICK, onoffClick);
			btOFF.addEventListener(MouseEvent.CLICK, onoffClick);

			l2 = new TextField();
			l2.defaultTextFormat = f;
      l2.setTextFormat( f );
			l2.text = "Дата/Время:";
			l2.autoSize = TextFieldAutoSize.LEFT;
			l2.textColor = 0x484848;
			l2.selectable = false;
			l2.y = l1.y + l1.height + 30;

			ebDate = new TextField();
			ebDate.defaultTextFormat = fi;
      ebDate.setTextFormat( fi );
			ebDate.text = "12:00 dd/mm/yyyy";
			ebDate.autoSize = TextFieldAutoSize.NONE;
			ebDate.textColor = 0x484848;
			ebDate.background = true;
			ebDate.backgroundColor = 0xffffff;
			ebDate.border = true;
			ebDate.borderColor = 0x000000;
			ebDate.selectable = true;
      ebDate.mouseEnabled = true;
      ebDate.type = TextFieldType.INPUT;
			ebDate.x = 120;
			ebDate.y = l1.y + l1.height + 28;
			ebDate.width = 150;
			ebDate.height = 24;

			l3 = new TextField();
			l3.defaultTextFormat = f;
      l3.setTextFormat( f );
			l3.text = "Заголовок:";
			l3.autoSize = TextFieldAutoSize.LEFT;
			l3.textColor = 0x484848;
			l3.selectable = false;
			l3.y = l2.y + l2.height + 30;

			ebTitle = new TextField();
			ebTitle.defaultTextFormat = fi;
      ebTitle.setTextFormat( fi );
			ebTitle.text = "";
			ebTitle.autoSize = TextFieldAutoSize.NONE;
			ebTitle.textColor = 0x484848;
			ebTitle.background = true;
			ebTitle.backgroundColor = 0xffffff;
			ebTitle.border = true;
			ebTitle.borderColor = 0x000000;
			ebTitle.selectable = true;
      ebTitle.mouseEnabled = true;
      ebTitle.type = TextFieldType.INPUT;
			ebTitle.x = 120;
			ebTitle.y = l2.y + l2.height + 28;
			ebTitle.width = 500;
			ebTitle.height = 24;


			l4 = new TextField();
			l4.defaultTextFormat = f;
      l4.setTextFormat( f );
			l4.text = "Картинка:";
			l4.autoSize = TextFieldAutoSize.LEFT;
			l4.textColor = 0x484848;
			l4.selectable = false;
			l4.y = l3.y + l3.height + 30;
			
			btpic1 = new StandardButton( "Общая", 120, l4.y - 4, StandardButton.GREY_BUTTON);
			btpic1.addEventListener(MouseEvent.CLICK, picClick);
			btpic2 = new StandardButton( "Дума", btpic1.x + btpic1.width + 5, l4.y - 4, StandardButton.GREY_BUTTON);
			btpic2.addEventListener(MouseEvent.CLICK, picClick);
			btpic3 = new StandardButton( "Выбрать...", btpic2.x + btpic2.width + 5, l4.y - 4, StandardButton.GREY_BUTTON);
			btpic3.addEventListener(MouseEvent.CLICK, picClick);
			picClick(null);
			
			btSend = new StandardButton( "Отправить", 120, l4.y + 70, StandardButton.RED_BUTTON);
			btSend.addEventListener(MouseEvent.CLICK, sendClick);
											
			addChild(bg);
			addChild(cnst);
			addChild(l1);
			addChild(btON);
			addChild(btOFF);
			addChild(l2);
			addChild(ebDate);
			addChild(l3);
			addChild(ebTitle);
			addChild(l4);
			addChild(btpic1);
			addChild(btpic2);
			addChild(btpic3);
			
			addChild(btSend);
			
			nc = new NetConnection();
			nc.client = this;
			nc.addEventListener(NetStatusEvent.NET_STATUS, NetConnectionStatus);

			t = new Timer(2000, 1);
			t.addEventListener(TimerEvent.TIMER, connect);

			connect();
			tenb = 0;

			var urlLoader : URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, calIP);
			urlLoader.load(new URLRequest(ipgeturl));
		}
		private function calIP(e:Event):void
		{
			ip = e.target.data;
			hash = MD5.hash(ip + sp);
		}


		public function set tenb( value: uint ) : void
    {
			if (tst != value) {
				tst = value;
				switch (tst) {
				case 0:
					btON.state = StandardButton.NORMAL;
					btOFF.state = StandardButton.PUSHED;
					break;
				case 1:
					btON.state = StandardButton.PUSHED;
					btOFF.state = StandardButton.NORMAL;
					break;
				}
			}
    }

    private function onoffClick(e:Event):void {
				if (e.target == btON) { tenb = 1; } else { tenb = 0; }
		} 

		public function set tpicinx( value: int ) : void
    {
			if (picinx != value) {
				picinx = value;
				switch (picinx) {
				case 0:
					btpic1.state = StandardButton.PUSHED;
					btpic2.state = StandardButton.NORMAL;
					break;
				case 1:
					btpic1.state = StandardButton.NORMAL;
					btpic2.state = StandardButton.PUSHED;
					break;
				}
			}
    }
    
    private function picClick(e:Event):void {
    		if (e == null) {
					pic	= piccommon;			
					tpicinx = 0;
    		} else if (e.target == btpic1) {
					pic	= piccommon;			
					tpicinx = 0;
				} else if (e.target == btpic2) {
					pic	= picduma;
					tpicinx = 1;
				}
		} 
		
		private function sendClick(e:Event) : void {
				if (conn) {
					nc.call("setTrslParams", null, hash, tst, ebDate.text, ebTitle.text, 2, pic);					
				}
		}

		public function get tenb() : uint
    {
			return tst;
    }

    public function set status( value: uint ) : void
    {
			conn = value;
			if (conn) {
				btSend.state = StandardButton.NORMAL;
			} else {
				btSend.state = StandardButton.INACTIVE;
			}
    }

		public function get status() : uint
    {
			return conn;
    }
    
		private function connect(event:TimerEvent = null):void 
		{
			if (cnst.status != 2) { cnst.status = 2; }
			nc.connect(serverName, true );
		}

		public	function NetConnectionStatus(event:NetStatusEvent) : void
		{
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
										cnst.status = 1;
										status = 1;
                    break;
                case "NetConnection.Connect.Closed":
			              cnst.status = 2;
			              status = 0;
			              t.start();
                    break;
                case "NetConnection.Connect.Failed":
			              t.start();
			              status = 0;
                    break;
            }
		}

		public function onBWDone(): void {		}
		public function updateTrslt (param1:int, param2:String, param3:String, param4:int, param5:String) : void {		}
	}
}
