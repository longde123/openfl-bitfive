package flash.display;
#if js
import flash.geom.Point;
import flash.Lib;
import js.Browser;
import js.html.Element;
//
class Stage extends DisplayObjectContainer {
	public var align:StageAlign;
	public var quality:String;
	public var scaleMode:StageScaleMode;
	public var displayState:StageDisplayState;
	public var stageWidth(get, null):Int;
	public var stageHeight(get, null):Int;
	public var showDefaultContextMenu:Bool;
	public var frameRate:Float = 0; // should be retrieved from XML instead.
	public var focus:InteractiveObject;
	public var mousePos:Point;
	/** Whether device is touch screen.
	 * If device dispatches touch events, these are more reliable source of mouse coordinates */
	private var isTouchScreen:Bool = false;
	//
	private var qTimeStamp:Int;
	public function new() {
		super();
		var s = component.style;
		s.position = "absolute";
		s.overflow = "hidden";
		s.width = s.height = "100%";
		qTimeStamp = Lib.getTimer();
		Lib.requestAnimationFrame(onAnimationFrame);
		mousePos = new Point();
		// mouse move listener (to keep track of mouseX/mouseY)
		addEventListener(flash.events.MouseEvent.MOUSE_MOVE, onMouseMove);
		// touch events (to prevent scrolling and to track mouse position):
		addEventListener("touchstart", onTouch);
		addEventListener("touchend", onTouch);
		addEventListener("touchmove", function(e) {
			onTouch(e);
			e.preventDefault();
			return false;
		});
	}
	private function onTouch(e:js.html.TouchEvent):Void {
		isTouchScreen = true;
		if (e.targetTouches.length > 0) {
			mousePos.x = e.targetTouches[0].pageX;
			mousePos.y = e.targetTouches[0].pageY;
		}
	}
	private function onMouseMove(e:js.html.MouseEvent):Void {
		if (!isTouchScreen) {
			mousePos.x = e.pageX;
			mousePos.y = e.pageY;
		}
	}
	// a not-very-smart method of adding Stage listeners to Window, as opposed to it's Div.
	override public function addEventListener(type:String, listener:Dynamic -> Void,
	useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		var o = component; component = untyped window;
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		component = o;
	}
	override public function removeEventListener(type:String, listener:Dynamic -> Void,
	useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		var o = component; component = untyped window;
		super.removeEventListener(type, listener, useCapture, priority, useWeakReference);
		component = o;
	}
	function get_stageWidth():Int {
		return Browser.window.innerWidth;
	}
	function get_stageHeight():Int {
		return Browser.window.innerHeight;
	}
	override private function get_stage():Stage {
		return this;
	}
	private function onAnimationFrame() {
		var t = Lib.getTimer();
		if (frameRate <= 0 || t - qTimeStamp >= 1000 / frameRate) {
			qTimeStamp = t;
			var e = new flash.events.Event(flash.events.Event.ENTER_FRAME);
			this.broadcastEvent(e);
		}
		flash.Lib.requestAnimationFrame(onAnimationFrame);
	}
}
#end