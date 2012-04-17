package
{
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.ContextMenuBuiltInItems;
    import flash.events.ContextMenuEvent;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
   
    [SWF (width = "428", height = "242", backgroundColor="#FFFFFF")]
    public class kprftvlive extends Sprite
    {
        [Embed (source = "../bin/kprftvlivec.swf", mimeType = "application/octet-stream")]
        private var content:Class;
        
        private var cntmenu         :ContextMenu;
        private var vartext1        :String = "KPRF.TV live TV player /ver.: 4.0.1/";
        private var vartext2        :String = "The author of the player -- Evgeniy Kozin (© CPRF)";
 
        public function kprftvlive():void
        {
            var loader:Loader = new Loader();
            addChild(loader);
            loader.loadBytes(new content(), new LoaderContext(false, new ApplicationDomain()));
            
            cntmenu = new ContextMenu();
            cntmenu.hideBuiltInItems();

            var cmi1:ContextMenuItem = new ContextMenuItem(vartext1);
            var cmi2:ContextMenuItem = new ContextMenuItem(vartext2);
            cmi1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectedKPRFTV);
            cmi2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectedKOZIN);      
            cntmenu.customItems.push(cmi1);
            cntmenu.customItems.push(cmi2);
            this.contextMenu = cntmenu;
        }
        
        private function menuItemSelectedKPRFTV(evt:ContextMenuEvent):void
        {
          navigateToURL (new URLRequest ("http://kprf.tv/online/"), "_blank");
        }
        
        private function menuItemSelectedKOZIN(evt:ContextMenuEvent):void
        {
          navigateToURL (new URLRequest ("http://vk.com/id8623720"), "_blank");
        }
    }
 
}
