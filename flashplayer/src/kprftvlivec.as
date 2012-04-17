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
  import flash.net.navigateToURL;
  import flash.net.URLRequest;
  import flash.events.MouseEvent;
  import flash.events.AsyncErrorEvent;
  import flash.events.FullScreenEvent;
  import flash.net.URLLoader;
  import flash.geom.Rectangle;

  [SWF(width = "428", height = "242")]
  
  public class kprftvlivec extends Sprite {
    private var redFrame       :Shape;

    private var dataServer      :String = "http://kprf.tv/param_live_kprftv.xml";
    private var dataTimer       :Timer;
    private var dataXML         :XML;
    private var dataXMLLoader   :URLLoader;
    private var dataXMLRequest  :URLRequest;
    
    private var mfWidth         :Number = 426;
    private var mfHeight        :Number = 240;
    
    private var nc              :NetConnection = null;
    private var ns              :NetStream = null;
    private var serverName      :String = "rtmp://live1.kprf.tv/rtp";
    private var streamName      :String = "streamld";
    
    private var video            :Video;
    private var sbuff            :MsgBuffer;
    
    public function kprftvlivec () : void
    {
      if (stage) {
        init (null);
      } else {
        addEventListener (Event.ADDED_TO_STAGE, init);
      }
    }

    private function init (e:Event = null):void 
    {
      removeEventListener (Event.ADDED_TO_STAGE, init);
      Security.allowDomain ("*");
      stage.scaleMode = StageScaleMode.SHOW_ALL;

  
      var myMatrix:Matrix = new Matrix();
      myMatrix.createGradientBox(mfWidth, mfHeight, Math.PI * 0.5, 0, 0);
        
      redFrame = new Shape;
      redFrame.graphics.lineStyle(1, 0xd50000, 1, true, LineScaleMode.NONE, CapsStyle.ROUND);
      redFrame.graphics.beginGradientFill(GradientType.LINEAR, [0xc0c0c0, 0x7b7b7b, 0xf3f3f3], [100, 100, 100], [0, 128, 255], myMatrix);
      redFrame.graphics.drawRect(0, 0, mfWidth + 1, mfHeight + 1 );

      video = new Video(mfWidth, mfHeight);
      video.x = 1;
      video.y = 1;
      video.smoothing = true;
      
      nc = new NetConnection();
      nc.addEventListener(NetStatusEvent.NET_STATUS, NetConnectionStatus);
      nc.client = this;

      sbuff = new MsgBuffer();
      sbuff.x = Math.round(mfWidth / 2) - Math.round(sbuff.width / 2);
      sbuff.y = Math.round(mfHeight / 2) - Math.round(sbuff.height / 2);
                       
      addChild(redFrame);
      addChild(video);
      addChild(sbuff);
      sbuff.Show();      
      nc.connect(serverName, "user", "pass" );   
    }
       
    public  function NetConnectionStatus(event:NetStatusEvent) : void
    {
      switch (event.info.code) {
        case "NetConnection.Connect.Success":
          removeChild(sbuff);
          sbuff.Hide();
          ns = new NetStream(nc);
          ns.bufferTime = 3;
          video.attachNetStream(ns);
          ns.addEventListener(NetStatusEvent.NET_STATUS, NetStreamStatus);
          ns.play(streamName);
          break;
      }
    }
    public  function NetStreamStatus(event:NetStatusEvent) : void
    {            
      switch (event.info.code) {
        case "NetStream.Play.PublishNotify":       
        case "NetStream.Buffer.Empty":
        case "NetStream.Play.Start":
          addChild(sbuff);
          sbuff.Show();
          break;        
        case "NetStream.Buffer.Full":
          removeChild(sbuff);
          sbuff.Hide();
          break;
      }  
    }    
  }
}
