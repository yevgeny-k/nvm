package
{
  import flash.display.Sprite;
  import flash.text.TextField;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.LineScaleMode;
 	import flash.display.CapsStyle;
 	import flash.display.JointStyle;
 	import flash.filters.BevelFilter;
 	import flash.filters.BitmapFilterType
 	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
 	import flash.display.Shape;

 	import flash.text.TextField;
  import flash.text.TextFieldType;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.text.TextFormatAlign;
  
  internal class StandardButtonDS extends Sprite
  {
  	private static const STROKE				:int = 0x686868;

    public static const BORDER_COL		:int = 0xd8dfea;
    public static const BORDER2_COL		:int = 0xc0cad5;
    
  	public static const TXT_UNDERLINE	:int = 0x0001;
    public static const TXT_BOLD			:int = 0x0002;
    public static const TXT_MULTILINE	:int = 0x0004;
    public static const TXT_CENTER		:int = 0x0008;
    public static const TXT_AUTOSIZE	:int = 0x0010;
    public static const TXT_INPUT			:int = 0x0020;
    public static const TXT_BORDER		:int = 0x0040;
    public static const TXT_HTML			:int = 0x0080;

    public static var fnm					:String = "Arial";
    private var bevel							:BevelFilter;
    private var grow							:BitmapFilter;
    private var conr							:uint = 0;
    
    public function StandardButtonDS( bt:uint, state:uint, s:String ):void
    {
    	var fillcolors	:Array = [];
      var txtCol			:uint = 0;
      
			bevel = new BevelFilter();
			var myFilters:Array = new Array();

			if ( isPar(bt, StandardButton.RED_BUTTON) ) {
        fillcolors = (state != 2) ? [0xf4b0b0, 0xa10000] : [0xdb5959, 0xb50000];
        bevel.highlightColor = 0xf7d4d4;
				bevel.shadowColor = 0x7d0202;
			}
			if ( isPar(bt, StandardButton.GREY_BUTTON) ) {
        fillcolors = (state != 2) ? [0xd2d2d2, 0x555555] : [0xb0b0b0, 0x878787];
        bevel.highlightColor = 0xececec;
				bevel.shadowColor = 0x636363;
      }
      if ( isPar(bt, StandardButton.GREEN_BUTTON) ) {
        fillcolors = (state != 2) ? [0x05e412, 0x06870d] : [0x00b00a, 0x008a08];
        bevel.highlightColor = 0x80ef86;
				bevel.shadowColor = 0x026507;
      }
      switch (state)
      {
			case StandardButton.BUTTON_UP:
      	txtCol = 0xFFFFFF;
      	break;
			case StandardButton.BUTTON_OVER:
      	//txtCol = 0xeffbe60;
      	txtCol = 0xFFFFFF;
				grow = new GlowFilter(0xffd200, 0.8, 8, 8, 2, BitmapFilterQuality.LOW, false, false); 
				myFilters.push(grow);
      	break;
			case StandardButton.BUTTON_DOWN:
      	txtCol = 0xFFFFFF;
      	break;
     	case StandardButton.BUTTON_INACTIVE:
      	txtCol = 0xCCCCCC;
				if ( isPar(bt, StandardButton.RED_BUTTON) ) {
		      fillcolors = [0xf09c9c, 0xf09c9c];
				}     
				if ( isPar(bt, StandardButton.GREY_BUTTON) ) {
		      fillcolors = [0xd6d6d6, 0xd6d6d6];
				}  
				if ( isPar(bt, StandardButton.GREEN_BUTTON) ) {
		      fillcolors = [0x04e411, 0x04e411];
				}   	
      	break;
     	}

     	if ( isPar(bt, StandardButton.ROUND_BUTTON) ) {
		      conr = 10;
			}   
       
      var txt:TextField = addText( 10, 0, 1000, 14, s, txtCol, TXT_AUTOSIZE + TXT_BOLD );
      
			var w:uint = 0;
			if ( isPar(bt, StandardButton.NARROW_BUTTON) ) {
				w = txt.textWidth + 10; 
			} else {
				w = txt.textWidth + 40; 
			}
      const h:uint = 28;

      txt.y = Math.round((h - txt.textHeight) / 2) - 2;
      txt.x = Math.round((w - txt.textWidth) / 2) - 2;

			var myMatrix:Matrix = new Matrix();
			myMatrix.createGradientBox(w, h, Math.PI * 0.5, 0, 0);


			
			bevel.blurX = 0;
			bevel.blurY = 0;
			bevel.quality = 1;
			bevel.angle = (state != 2) ? 45 : 225;
			bevel.distance = 1;
			bevel.shadowAlpha = 1;
			bevel.highlightAlpha = 1;
			bevel.type = BitmapFilterType.INNER;
			bevel.strength = 1;

			var centr:Shape = new Shape;
			
			centr.graphics.lineStyle();
			centr.graphics.beginGradientFill(GradientType.LINEAR, fillcolors, [100, 100], [0, 255], myMatrix);
			centr.graphics.drawRoundRect(1, 1, w-1, h-1, conr);

		
			if ( (state == StandardButton.BUTTON_INACTIVE) || isPar(bt, StandardButton.FLAT_BUTTON) ) {
			} else {
				myFilters.push(bevel);
			}

			centr.filters = myFilters;
			
			centr.graphics.endFill();
			addChild(centr);
			addChild(txt);
			
			if ( !isPar(bt, StandardButton.FLAT_BUTTON) ) {
				this.graphics.lineStyle(1, STROKE);
				this.graphics.drawRoundRect(0, 0, w, h, conr);
			}
    }
    private static function addText( x:int, y:int, w:int, fsz:int, s:String, tc:int = 0, prm:int = 0, h_:int = 0 ):TextField
    {
      var f:TextFormat = getTxtFormat( fsz, prm );
      
      var tf:TextField = new TextField();
      tf.defaultTextFormat = f;
      tf.setTextFormat( f );
      tf.x = x;
      tf.y = y;
      tf.width = w;
	 

      if ( s == null )
        tf.text = "";
      else
      {
        if ( isPar(prm, TXT_HTML) )
          tf.htmlText = s;
        else
          tf.text = s;
      }
      
      if ( isPar(prm, TXT_MULTILINE) )
      {
        tf.wordWrap = true;
        tf.multiline = true;
      }

      if ( isPar(prm, TXT_AUTOSIZE)  ||  w == 0 )
        tf.autoSize = TextFieldAutoSize.LEFT;
        
      if ( isPar(prm, TXT_INPUT) )
      {
        tf.selectable = true;
        tf.mouseEnabled = true;
        tf.type = TextFieldType.INPUT;
      } else
      {
        //!!tf.selectable = false;
      }
      
      if ( isPar(prm, TXT_BORDER) )
      {
        addBorder( tf );
      }
      
      var h:int = (fsz * 1.6); // Magic constant...
      tf.height = (h_ == 0)  ?  h  :  h_;
      
      if ( isPar(prm, TXT_AUTOSIZE) )
      {
        h = tf.height;
        w = (w == 0) ? tf.width : Math.min( w, tf.width );
        tf.autoSize = TextFieldAutoSize.NONE;
        tf.height = h;
        tf.width = w;// + 2;
        if ( h_ > 0  &&  h_ < h )
          tf.height = h_;
      }
      
      tf.textColor = tc;
      
      if ( s != null  &&  isPar(prm, TXT_HTML) )
        tf.htmlText = s;

      return tf;
    }

    public static function getTxtFormat( fsz:int, prm:int = 0 ):TextFormat
    {
      var f:TextFormat = new TextFormat();
      f.font = fnm;
      f.size = fsz;
      f.underline = isPar(prm, TXT_UNDERLINE);
      f.bold = isPar(prm, TXT_BOLD);
      f.align = isPar(prm, TXT_CENTER) ? TextFormatAlign.CENTER : TextFormatAlign.LEFT;
      return f;
    }
    
    public static function addBorder( tf:TextField ):void
    {
      tf.background = true;
      tf.border = true;
      tf.borderColor = BORDER2_COL;
    }
            
    private static function isPar( p:int, pp:int ):Boolean
    {
      return (p & pp) != 0;
    }
  }
}
