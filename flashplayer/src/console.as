package {
	public final class console {
		import flash.external.ExternalInterface;
		
		public static function log(arg :String) : void {
			ExternalInterface.call('console.log', arg);
		}
	}
}
