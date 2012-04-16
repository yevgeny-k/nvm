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

    public function toggleToFullScreen(): void {
      console.log("toggle FullScreen");      
      if(stage.displayState != StageDisplayState.FULL_SCREEN){
        stage.fullScreenSourceRect = new Rectangle(video.x, video.y, video.width, video.height);
        stage.displayState = StageDisplayState.FULL_SCREEN;
      }
    }
    
    public function toggleToNormalScreen(): void {
      console.log("toggle NormalScreen");      
      if(stage.displayState != StageDisplayState.NORMAL){
        stage.displayState = StageDisplayState.NORMAL;
        stage.fullScreenSourceRect = null;
      }
    }
        
    private function fullScreenEventHandle(event:FullScreenEvent) :void  {
       if (event.fullScreen) {
          removeChild(cnst);  
          removeChild(bfullScreen);  
          removeChild(redFrame);
          removeChild(qbHD);
          removeChild(qbST);
          removeChild(qbSD);
          removeChild(bShare);
          removeChild(bEmbed);      
          removeChild(qLabel);
          removeChild(lShare);
          removeChild(wtch);
      
       } else {
        
          addChild(redFrame);
          addChild(qbHD);
          addChild(qbST);
          addChild(qbSD);
          addChild(bShare);
          addChild(bEmbed);      
          addChild(qLabel);
          addChild(lShare);
          addChild(wtch);
          addChild(cnst);
          reStream();
       }
    }
    
    private function init(e:Event = null):void 
    {
      removeEventListener(Event.ADDED_TO_STAGE, init);
      Security.allowDomain( "*" );
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
      stage.addEventListener( FullScreenEvent.FULL_SCREEN, fullScreenEventHandle );

      cntmenu = new ContextMenu();
      cntmenu.hideBuiltInItems();

      var cmi1:ContextMenuItem = new ContextMenuItem(vartext1);
      var cmi2:ContextMenuItem = new ContextMenuItem(vartext2);
      cmi1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectedKPRFTV);
      cmi2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectedKOZIN);      
      cntmenu.customItems.push(cmi1);
      cntmenu.customItems.push(cmi2);
      this.contextMenu = cntmenu;
      
      var myMatrix:Matrix = new Matrix();
      myMatrix.createGradientBox(mfWidth, mfHeight, Math.PI * 0.5, 0, 0);
        
      
      redFrame = new Shape;
      redFrame.graphics.lineStyle(4, 0xd50000, 1, true, LineScaleMode.NONE, CapsStyle.ROUND);
      redFrame.graphics.beginGradientFill(GradientType.LINEAR, [0xc0c0c0, 0x7b7b7b, 0xf3f3f3], [100, 100, 100], [0, 128, 255], myMatrix);
      redFrame.graphics.drawRect(2, 2, mfWidth + 4, mfHeight + 4);

      var f:TextFormat = new TextFormat();
      f.font = "Arial";
      f.size = 15;
      f.bold = 1;
      qLabel = new TextField();
      qLabel.defaultTextFormat = f;
      qLabel.setTextFormat( f );
      qLabel.text = "Качество прямой трансляции:";
      qLabel.autoSize = TextFieldAutoSize.LEFT;
      qLabel.textColor = 0x484848;
      qLabel.selectable = false;
      qLabel.y = mfHeight+12;

      lShare = new TextField();
      lShare.defaultTextFormat = f;
      lShare.setTextFormat( f );
      lShare.text = "Распространение вещания:";
      lShare.autoSize = TextFieldAutoSize.LEFT;
      lShare.textColor = 0x484848;
      lShare.selectable = false;
      lShare.y = mfHeight+54;
              
      qbHD = new StandardButton( "Высокое", qLabel.width + 10, mfHeight + 10, StandardButton.RED_BUTTON );
      qbHD.state = StandardButton.INACTIVE;
      qbHD.addEventListener(MouseEvent.CLICK, chClick);
      qbST = new StandardButton( "Стандартное", qbHD.x + qbHD.width + 10, mfHeight + 10, StandardButton.RED_BUTTON);
      qbST.state = StandardButton.INACTIVE;
      qbST.addEventListener(MouseEvent.CLICK, chClick);
      qbSD = new StandardButton( "Только звук", qbST.x + qbST.width + 10, mfHeight + 10, StandardButton.RED_BUTTON);
      qbSD.state = StandardButton.INACTIVE;
      qbSD.addEventListener(MouseEvent.CLICK, chClick);

      
      bShare = new StandardButton( "Отправить", qLabel.width + 10, mfHeight + 52, StandardButton.GREEN_BUTTON);
      bEmbed = new StandardButton( "Встроить", bShare.x + bShare.width + 10, mfHeight + 52, StandardButton.GREY_BUTTON);
      bEmbed.addEventListener(MouseEvent.CLICK, ShareClick);

      bfullScreen = new StandardButton( "На весь экран", mfWidth - 150, mfHeight - 35, StandardButton.GREY_BUTTON + StandardButton.FLAT_BUTTON + StandardButton.NARROW_BUTTON);
      bfullScreen.x = mfWidth - bfullScreen.width - 10;
      bfullScreen.addEventListener(MouseEvent.CLICK, toggleFullScreenClick);

      wtch = new Watcher();
      wtch.x = mfWidth - 200;
      wtch.y = mfHeight + 44;
      
      cnst = new ConStatus();
      cnst.x = mfWidth - cnst.width + 4;
      cnst.y = 4;

      video = new Video(mfWidth, mfHeight);
      video.x = 4;
      video.y = 4;
      video.smoothing = true;

      sbuff = new MsgBuffer();
      sbuff.x = Math.round(mfWidth / 2) - Math.round(sbuff.width / 2);
      sbuff.y = Math.round(mfHeight / 2) - Math.round(sbuff.height / 2);

      shareD = new ShareDlg(mfWidth, mfHeight);
      shareD.addEventListener("CloseShare", ShareClick);
                  
      addChild(redFrame);
      addChild(qbHD);
      addChild(qbST);
      addChild(qbSD);
      addChild(bShare);
      addChild(bEmbed);      
      addChild(qLabel);
      addChild(lShare);
      addChild(wtch);
      addChild(cnst);


      ncClientObj = new Object();
  
      //ncClientObj.onMetaData = metaDataHandler;
      nc = new NetConnection();
      nc.addEventListener(NetStatusEvent.NET_STATUS, NetConnectionStatus);
      nc.client = this;
      
      dataTimer = new Timer(25000 + (Math.round (Math.random ()*400)), 1);
      dataTimer.addEventListener(TimerEvent.TIMER, getTrData);
      dataXMLLoader = new URLLoader();
      dataXML = new XML();
      dataXMLRequest = new URLRequest(dataServer);
      dataXMLLoader.addEventListener(Event.COMPLETE, loadedTrData);
            
      connectTimer = new Timer(4500 + (Math.round (Math.random ()*400)), 1);
      connectTimer.addEventListener(TimerEvent.TIMER, connect);

      connect();
    
    }

      
  public function onMetaData(infoObject: Object): void {
    //console.log("metadata: duration=" + infoObject.duration + " framerate=" + infoObject.framerate);
  }
     
//////// GET DATA ///////////////
  private function getTrData(event:TimerEvent = null): void 
  {
    dataXMLLoader.data = "";
    dataXMLLoader.load(dataXMLRequest);
    dataTimer.reset();
    dataTimer.start();
  }

  private function loadedTrData(e:Event): void
  {
    console.log("Config loaded");
    dataXML = new XML(e.target.data);

    serverName  = dataXML.url.*;
    FtrEnable    = dataXML.enabled.*;
    FtrEnablePlay= dataXML.enabledPlay.*;
    FtrDate      = dataXML.date.*;
    FtrTitle     = dataXML.title.*;
    FtrPic       = dataXML.picture.*;
    wtch.count   = dataXML.numberviewers.*;
    if (!isPlayNow) {
      updateStreams (dataXML.streams.stream.(@type=="SD"), dataXML.streams.stream.(@type=="SD").@enabled, dataXML.streams.stream.(@type=="HD"), dataXML.streams.stream.(@type=="HD").@enabled);
      PlayBC(null); 
    }
  }
  
//////// END GET DATA ///////////



  private function menuItemSelectedKPRFTV(evt:ContextMenuEvent):void
  {
    navigateToURL (new URLRequest ("http://kprf.tv/online/"), "_blank");
  }
  
  private function menuItemSelectedKOZIN(evt:ContextMenuEvent):void
  {
    navigateToURL (new URLRequest ("http://vk.com/id8623720"), "_blank");
  }
        
    private function connect(event:TimerEvent = null):void 
    {
      if (cnst.status != 2) { cnst.status = 2; }
      if (serverName != "") {
        nc.connect(serverName, "user", "pass" );
      } else {
        connectTimer.reset();
        connectTimer.start();
      }
    }

    public  function NetConnectionStatus(event:NetStatusEvent) : void
    {
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
                    console.log("NetConnection.Connect.Success");
                    cnst.status = 1;
                    conn = 1;
                    //updateStreams (dataXML.streams.stream.(@type=="SD"), dataXML.streams.stream.(@type=="SD").@enabled, dataXML.streams.stream.(@type=="HD"), dataXML.streams.stream.(@type=="HD").@enabled);
                    getTrData();               
                    break;
                case "NetConnection.Connect.Closed":
                    console.log("NetConnection.Connect.Closed");
                    cnst.status = 2;
                    conn = 0;
                    wtch.count = 0;
                    connectTimer.reset();
                    connectTimer.start();
                    toggleToNormalScreen();
                    break;
                case "NetConnection.Connect.Failed":
                    console.log("NetConnection.Connect.Failed");
                    conn = 0;
                    wtch.count = 0;
                    connectTimer.reset();
                    connectTimer.start();
                    toggleToNormalScreen();
                    break;
            }
    }



    private function set FtrEnable( value: uint ) : void
    {
      if (value != trEnable) {
        trEnable = value;
        if (trEnable == 1) {
          //ibLogo.toPos1 ();
        } else {
          //removeChild(nmtr);
          //ibLogo.toStartPos ();
        }
      }
    }
    
    private function set FtrEnablePlay( value: uint ) : void
    {
      if (value != trEnablePlay) {
        trEnablePlay = value;
       // nmtr.plbt = trEnablePlay;
      }
    }
    
    private function set FtrDate( value: String ) : void
    {
      if (value != trDate) {
        trDate = value;
        //nmtr.dt = trDate;
      }
    }

    private function set FtrTitle( value: String ) : void
    {
      if (value != trTitle) {
        trTitle = value;
       // nmtr.nm = trTitle;
      }
    }

    private function set FtrPic( value: String ) : void
    {
      if (value != trPic) {
        trPic = value;
        //nmtr.pc = trPic;
      }
    }
    
    private function set FtrQV( value: uint ) : void
    {
      if (value != trQV) {
        trQV = value;
      }
    }

    public function updateCountConnetion(returnStr : int) : void
    {
      wtch.count = returnStr;
    }


    public function showTr( e:Event ) : void
    {
      if ( (trEnable == 1) && (!isPlayNow)) {
        //addChild(nmtr);
      }
    }

    public function onBWDone() : void {    }
    

    public function updateStreams (param1:String, param2:int, param3:String, param4:int) : void
    {
      streamName    = param1;
      streamE        = param2;
      streamHDName  = param3;
      streamHDE      = param4;
      if (streamE) {
        qbST.state = StandardButton.NORMAL;
        qbSD.state = StandardButton.NORMAL;
      } else {
        qbST.state = StandardButton.INACTIVE;
        qbSD.state = StandardButton.INACTIVE;
      }
      
      if (streamHDE) {
        qbHD.state = StandardButton.NORMAL;
      } else {
        qbHD.state = StandardButton.INACTIVE;
      }

      if (streamE || streamHDE) {
        strenbl = 1;
        var i: int = 0;
        i = curstrm;
        if ( (streamE) && (curstrm == 0) ) {
          i = 2;
        } else if ( (streamHDE) && (curstrm == 0) ) {
          i = 3;
        }
        
        if ( (!streamHDE) && (curstrm == 3) ) {
          i = 2;
        } else if ( (!streamE) && ( (curstrm == 1) || (curstrm == 2) ) ) {
          i = 3;
        }

        switch (curstrm) {
        case 1:
          if (streamE) {
            qbSD.state = StandardButton.PUSHED;
            qbST.state = StandardButton.NORMAL;
          }
          if (streamHDE) {
            qbHD.state = StandardButton.NORMAL;
          }
          break;
        case 2:
            
          if (streamE) {
            qbSD.state = StandardButton.NORMAL;
            qbST.state = StandardButton.PUSHED;
          }
          if (streamHDE) {
            qbHD.state = StandardButton.NORMAL;
          }
          break;
        case 3:
          if (streamE) {
            qbSD.state = StandardButton.NORMAL;
            qbST.state = StandardButton.NORMAL;
          }
          if (streamHDE) {
            qbHD.state = StandardButton.PUSHED;
          }
          break;
        }
                
        chgStrm = i;
      } else {
        strenbl = 0;
      }
      
    }
    
    public function PlayBC( e:Event ) : void {
      //nmtr.plbt = 0;
      //nmtr.playWaitButton = 1;
      isbePlayed = 0;
      reStream();
    } 

    private function chClick(e:Event):void {
        if ((e.target == qbHD) && (qbHD.state == StandardButton.NORMAL)){
          chgStrm = 3;
        } else if ((e.target == qbST) && (qbST.state == StandardButton.NORMAL)){
          chgStrm = 2;
        } else if ((e.target == qbSD) && (qbSD.state == StandardButton.NORMAL)){
          chgStrm = 1;
        }
    }  

    private function toggleFullScreenClick(e:Event) :void {
      removeChild(bfullScreen); 
      toggleToFullScreen();
    } 

        
    public function ShareClick( e:Event ) : void
    {
      if (shareE) {
        removeChild(shareD);
        shareE = 0;
      } else {
        addChild(shareD);
        shareE = 1;
      }
    }


    
    
    private function set chgStrm( value: int ) : void
    {
      if ( (!streamE) && (value == 1 || value == 2) ) { value = curstrm; }
      if ( (!streamHDE) && (value == 3) ) { value = curstrm; }
      
      if (curstrm != value) {
        curstrm = value;
        switch (curstrm) {
        case 1:
          if (streamE) {
            qbSD.state = StandardButton.PUSHED;
            qbST.state = StandardButton.NORMAL;
          }
          if (streamHDE) {
            qbHD.state = StandardButton.NORMAL;
          }
          break;
        case 2:
          if (streamE) {
            qbSD.state = StandardButton.NORMAL;
            qbST.state = StandardButton.PUSHED;
          }
          if (streamHDE) {
            qbHD.state = StandardButton.NORMAL;
          }
          break;
        case 3:
          if (streamE) {
            qbSD.state = StandardButton.NORMAL;
            qbST.state = StandardButton.NORMAL;
          }
          if (streamHDE) {
            qbHD.state = StandardButton.PUSHED;
          }
          break;
        }
        
      }  
      if (isPlayNow) { reStream(); }
    }

    private function reStream() : void {
      if (isPlayNow) {
            isPlayNow = 0;
            ns.close();
            onBan();
      }
      if (ns != null) { 
        ns.close();
        video.clear();
        ns = null;
      }

      ns = new NetStream(nc);
      ns.bufferTime = 3;

      video.attachNetStream(ns);
      ns.addEventListener(NetStatusEvent.NET_STATUS, NetStreamStatus);

      switch (curstrm) {
      case 1:
        ns.receiveAudio(true);
        ns.receiveVideo(false);
        ns.play(streamName);
        break;
      case 2:
        ns.receiveAudio(true);
        ns.receiveVideo(true);
        ns.play(streamName);
        break;
      case 3:
        ns.receiveAudio(true);
        ns.receiveVideo(true);
        ns.play(streamHDName);
        break;
      }      
    }

    public  function NetStreamStatus(event:NetStatusEvent) : void
    {
      console.log(event.info.code);
      // DEBUG
      //      qLabel.text = event.info.code;
            
      switch (event.info.code) {
        case "NetStream.Play.Reset":
          removeChild(bfullScreen);
          break;
        case "NetStream.Play.Start":
          isPlayNow = 1;
          isbePlayed = 1;
          offBan();
          addChild(sbuff);
          sbuff.Show();
          break;
        case "NetStream.Play.Stop":
        case "NetStream.Play.UnpublishNotify":
          if (!isbePlayed) {
            ns.close();
          }
          isPlayNow = 0;
          if (trEnablePlay) {
            //nmtr.plbt = 1;
          }
          break;          
        case "NetStream.Buffer.Full":
          if (isPlayNow) {
            removeChild(sbuff);
            sbuff.Hide();
            if ((stage.displayState != StageDisplayState.FULL_SCREEN) && (curstrm != 1)) {
              addChild(bfullScreen);
            }
          }
          break; 
        case "NetStream.Play.PublishNotify":       
        case "NetStream.Buffer.Empty":
          if (isPlayNow) {
            addChild(sbuff);
            sbuff.Show();
          } else {
            ns.close();
            removeChild(bfullScreen);
            toggleToNormalScreen();
            onBan();
          }
          break;
      }  
    }

    private  function onBan() : void
    {  
      video.clear();
      removeChild(video);
      removeChild(cnst);  
      //removeChild(bfullScreen);  
     

      addChild(cnst);          
    }

    private  function offBan() : void
    {  
      removeChild(cnst);  
      //removeChild(bfullScreen);        
      if (curstrm != 1) {
        if (trEnable == 1) {
          //removeChild(nmtr);
        }
      }
      addChild(video);
      addChild(cnst);  
    }
  }
}
