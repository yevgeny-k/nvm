package
{
	import flash.display.SimpleButton;

	public class StandardButton extends SimpleButton
  {
    internal var bt					:uint = 0;
    internal var s					:String = null;
    
    internal var btstate		:uint = 0;
    
    public static const RED_BUTTON		:uint = 0x0001;
    public static const GREY_BUTTON		:uint = 0x0002;
    public static const GREEN_BUTTON	:uint = 0x0004;
    public static const FLAT_BUTTON		:uint = 0x0008;
    public static const ROUND_BUTTON	:uint = 0x0010;
    public static const NARROW_BUTTON	:uint = 0x0020;
    
    public static const NORMAL:uint = 0;
    public static const PUSHED:uint = 1;
    public static const INACTIVE:uint = 2;

    public static const BUTTON_UP:uint = 0;
    public static const BUTTON_OVER:uint = 1;
		public static const BUTTON_DOWN:uint = 2;
    public static const BUTTON_INACTIVE:uint = 3;
    
    public function StandardButton( label:String, x:int, y:int, button_type:uint ):void
    {
      this.x = x;
      this.y = y;

      bt = button_type;
			useHandCursor = true;

      this.label = label;
    }
    
    public function set label( value: String ):void
    {
      s = value;
      updateButton();
    }
    
    public function get label(): String
    {
      return s;
    }

    public function set state( value: uint ):void
    {
      btstate = value;
      updateButton();
    }
    public function get state():uint
    {
      return btstate;
    }
            
    internal function updateButton():void
    {
    	switch (btstate)   	{
    	case StandardButton.NORMAL:
	      upState   = new StandardButtonDS( bt, BUTTON_UP, s );
  	    hitTestState = overState = new StandardButtonDS( bt, BUTTON_OVER, s );
  	    downState = new StandardButtonDS( bt, BUTTON_DOWN, s );
				break;
    	case StandardButton.PUSHED:
	      upState   =  hitTestState = overState = downState = new StandardButtonDS( bt, BUTTON_DOWN, s );
  	  	break;
    	case StandardButton.INACTIVE:
	      upState   =  hitTestState = overState = downState = new StandardButtonDS( bt, BUTTON_INACTIVE, s );
  	   	break;
  	  }

  	  if (btstate != StandardButton.INACTIVE) {
      	useHandCursor = true;
      } else {
      	useHandCursor = false;
      }
    }
  }
}
