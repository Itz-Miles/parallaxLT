#if (flixel >= "5.3.1")
package flixel_5_3_1;

import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.FlxObject;
import flixel.math.FlxPoint;

enum Direction {
	HORIZONTAL;
	VERTICAL;
	NULL;
}

/**
 * @author Itz_Miles
 */
class ParallaxSprite extends FlxSprite {
	private var pointOne:FlxObject = new FlxObject();
	private var pointTwo:FlxObject = new FlxObject();
	private var _bufferOne:FlxPoint = new FlxPoint();
	private var _bufferTwo:FlxPoint = new FlxPoint();

	public var direction:Direction = Direction.NULL;

	public function new(graphic:FlxGraphicAsset, x:Float = 0, y:Float = 0) {
		super(x, y);
		loadGraphic(graphic);
		origin.set(0, 0);
	}

	/**
	 * Sets the sprite's skew factors and direction. These can be set independently but may lead to unexpected behaivor.
	 * @param anchorX       the camera scroll x where the sprite's x axis appears unchanged.
	 * @param anchorY       the camera scroll y where the sprite's y axis appears unchanged.
	 * @param scrollOneX        the horizontal scroll factor of the first point.
	 * @param scrollOneY        the vertical scroll factor of the first point.
	 * @param scrollTwoX        the horizontal scroll factor fo the second point.
	 * @param scrollTwoY        the vertical scroll factor of the second point.
	 * @param direct        the sprite's direction, which determines the skew.
	 * 
	 * @param direct_horizontal     direct argument. typically for ceilings and floors. Skews on the x axis, stretches on the y axis.
	 * @param direct_vertical       direct argument. typically for walls and backdrops. Stretches on the x axis, skews on the y axis.
	**/
	public function fixate(anchorX:Int = 0, anchorY:Int = 0, scrollOneX:Float = 1, scrollOneY:Float = 1, scrollTwoX:Float = 1.1, scrollTwoY:Float = 1.1,
			direct:String = 'horizontal'):Void {
		pointOne.scrollFactor.set(1, 1);
		pointTwo.scrollFactor.set(1, 1);
		pointOne.setPosition((anchorX + x), (anchorY + y));
		switch (direct) {
			case 'horizontal' | 'orizzontale':
				direction = HORIZONTAL;
				pointTwo.setPosition((x + anchorX), (y + anchorY + frameHeight));
			case 'vertical' | 'vertikale' | 'verticale':
				direction = VERTICAL;
				pointTwo.setPosition((x + anchorX + frameWidth), (y + anchorY));
		}
		scrollFactor.set(scrollOneX, scrollOneY);
		pointOne.scrollFactor.set(scrollOneX, scrollOneY);
		pointTwo.scrollFactor.set(scrollTwoX, scrollTwoY);
		// wondering if there's enough demand to return the instance for chaining
	}

	override public function destroy():Void {
		pointOne = null;
		pointTwo = null;
		_bufferOne = null;
		_bufferTwo = null;
		direction = null;
		super.destroy();
	}

	@:noCompletion
	override function drawComplex(camera:FlxCamera):Void {
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		updateScrollMatrix();
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0) {
			updateTrig();

			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	override public function isSimpleRender(?camera:FlxCamera):Bool {
		if (!FlxG.renderBlit)
			return false;

		return super.isSimpleRender(camera) && (_matrix.c == 0) && (_matrix.b == 0);
	}

	private function updateScrollMatrix():Void {
		_bufferOne.copyFrom(pointOne.getScreenPosition());
		_bufferTwo.copyFrom(pointTwo.getScreenPosition());

		if (direction == HORIZONTAL) {
			_matrix.c = (_bufferTwo.x - _bufferOne.x) / frameHeight;
			scale.y = (_bufferTwo.y - _bufferOne.y) / frameHeight;
		} else if (direction == VERTICAL) {
			_matrix.b = (_bufferTwo.y - _bufferOne.y) / frameWidth;
			scale.x = (_bufferTwo.x - _bufferOne.x) / frameWidth;
		}
	}
}
#end
