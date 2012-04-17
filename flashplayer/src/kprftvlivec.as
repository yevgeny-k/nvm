package {
  import flash.display.Sprite;
  import flash.display.Stage;
  import flash.display.StageDisplayState;
  import flash.display.Graphics;
  import flash.display.Shape;
  import flash.display.CapsStyle;
  import flash.display.LineScaleMode;
   import flash.display.StageScaleMode;
  import flash.display.StageAlign;
   import flash.text.TextField;
  import flash.text.TextFieldType;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.events.Event;
  import flash.geom.Matrix;
  import flash.display.GradientType;
  import flash.events.NetStatusEvent;
  import flash.net.NetConnection;
  import flash.net.NetStream;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
  import flash.net.Responder;
  import flash.system.Security;
  import flash.media.Video;
  import flash.ui.ContextMenu;
  import flash.ui.ContextMenuItem;
  import flash.ui.ContextMenuBuiltInItems;
  import flash.events.ContextMenuEvent;
  import flash.net.navigateToURL;
  import flash.net.URLRequest;
  import flash.events.MouseEvent;
  import flash.events.AsyncErrorEvent;
  import flash.events.FullScreenEvent;
  import flash.net.URLLoader;
  import flash.geom.Rectangle;

  public class kprftvlivec extends Sprite {
    private  var mfWidth          :Number = 854;
    private  var mfHeight        :Number = 480;
    private  var redFrame        :Shape;
    private  var qbHD            :StandardButton;
    private  var qbST            :StandardButton;
    private  var qbSD            :StandardButton;
    private var qLabel          :TextField;

    private  var bShare          :StandardButton;
    private  var bEmbed          :StandardButton;    
    private var lShare          :TextField;

    private var bfullScreen      :StandardButton;

    private var cnst            :ConStatus;
    private var wtch            :Watcher;

    private var nc              :NetConnection = null;
    private var ns               :NetStream = null;

    private var serverName      :String = "rtmp://live1.kprf.tv/rtp";
    private var streamName      :String = "";
    private var streamE          :int = 0;
    private var streamHDName    :String = "";
    private var streamHDE        :int = 0;

    private var connectTimer    :Timer;

    private var trEnable        :int = 0;
    private var trEnablePlay    :int = -1;
    private var trDate          :String = "";
    private var trTitle          :String = "";
    private var trPic            :String = "";
    private var trQV            :int = 0;
    private var trCount          :int = 0;

    private var conn            :uint = 0;
    private var strenbl          :uint = 0;
    private var pl              :uint = 0;
    private var curstrm          :uint = 0;

    private var isPlayNow        :uint = 0;
    private var isbePlayed      :uint = 0;
    

    private var video            :Video;

    private var cntmenu          :ContextMenu;
    private var vartext1        :String = "KPRF.TV live TV player /ver.: 3.0.2-beta/";
    private var vartext2        :String = "The author of the player -- Evgeniy Kozin (© CPRF)";

    private var sbuff            :MsgBuffer;

    private var dataServer      :String = "http://kprf.tv/param_live_kprftv.xml";
    private var dataTimer       :Timer;
    private var dataXML         :XML;
    private var dataXMLLoader   :URLLoader;
    private var dataXMLRequest  :URLRequest;

    private var ncClientObj      :Object;

    private var shareE          :uint = 0;
    private var shareD          :ShareDlg;

    public function kprftvlivec () : void
    {
      console.log("App run");
      if ( stage ) {
        init( null );
      } else {
        addEventListener( Event.ADDED_TO_STAGE, init );
      }
    }

    private function init(e:Event = null):void 
    {
      removeEventListener(Event.ADDED_TO_STAGE, init);
      Security.allowDomain( "*" );
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
      stage.addEventListener( FullScreenEvent.FULL_SCREEN, fullScreenEventHandle );

      var myMatrix:Matrix = new Matrix();
      myMatrix.createGradientBox(mfWidth, mfHeight, Math.PI * 0.5, 0, 0);
        
      
      redFrame = new Shape;
      redFrame.graphics.lineStyle(4, 0xd50000, 1, true, LineScaleMode.NONE, CapsStyle.ROUND);
      redFrame.graphics.beginGradientFill(GradientType.LINEAR, [0xc0c0c0, 0x7b7b7b, 0xf3f3f3], [100, 100, 100], [0, 128, 255], myMatrix);
      redFrame.graphics.drawRect(2, 2, mfWidth + 4, mfHeight + 4);


                  
      addChild(redFrame);

    
    }
  }
}
