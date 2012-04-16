package
{
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
 
    [SWF (width = 862, height = 570, backgroundColor="#FFFFFF")]
    public class kprftvlive extends Sprite
    {
        [Embed (source = "../bin/kprftvlivec.swf", mimeType = "application/octet-stream")]
        private var content:Class;
 
        public function kprftvlive():void
        {
            var loader:Loader = new Loader();
            addChild(loader);
            loader.loadBytes(new content(), new LoaderContext(false, new ApplicationDomain()));
        }
    }
 
}
