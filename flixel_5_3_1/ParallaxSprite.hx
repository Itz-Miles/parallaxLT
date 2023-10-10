#if (flixel >= "5.3.1")
package flixel_5_3_1;

import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.FlxObject;
import flixel.math.FlxPoint;

/** An enum instance that determines what transformations are made to the sprite.
 * @param HORIZONTAL   typically for ceilings and floors. Skews on the x axis, scales on the y axis.
 * @param VERTICAL     typically for walls and backdrops. Scales on the x axis, skews on the y axis.
 * @param NULL         unintallized value. Not to be confused with bools `scales` and `skews`
 */
@enum
enum Direction
{
	HORIZONTAL;
	VERTICAL;
	NULL;
}

/**
 * The Parallax class is a FlxSprite extension that does linear transformations to mimic 3D graphics
 * @author Itz-Miles
 */
class ParallaxSprite extends FlxSprite
{
	private var pointOne:FlxObject = new FlxObject();
	private var pointTwo:FlxObject = new FlxObject();
	private var _bufferOne:FlxPoint = FlxPoint.get();
	private var _bufferTwo:FlxPoint = FlxPoint.get();

	/** An enum instance that determines what transformations are made to the sprite.
	 * @param HORIZONTAL    typically for ceilings and floors. Skews on the x axis, scales on the y axis.
	 * @param VERTICAL      typically for walls and backdrops. Scales on the x axis, skews on the y axis.
	 * @param NULL          unintallized value. Not to be confused with bools `scales` and `skews`
	**/
	public var direction:Direction = Direction.NULL;

	/**
	 * Creates a ParallaxSprite at specified position with a specified graphic.
	 * @param graphic		The graphic to load (uses haxeflixel's default if null)
	 * @param   X			The ParallaxSprite's initial X position.
	 * @param   Y			The ParllaxSprite's initial Y position.
	 */
	public function new(x:Float = 0, y:Float = 0, graphic:FlxGraphicAsset)
	{
		super(x, y. graphic);
		origin.set(0, 0);
	}

	/**
	 * Sets the sprites skew factors, direction.
	 * These can be set independently but may lead to unexpected behaivor.
	 * @param anchor 	   the camera's scroll where the sprite appears unchanged.
	 * @param scrollOne        the scroll factors of the first point.
	 * @param scrollTwo        the scroll factors of the second point.
	 * @param direction        the sprite's direction, which determines the skew.
	 * @param horizontal       typically for ceilings and floors. Skews on the x axis, scales on the y axis.
	 * @param vertical         typically for walls and backdrops. Scales on the x axis, skews on the y axis.
	**/
	public function fixate(anchorX:Int = 0, anchorY:Int = 0, scrollOneX:Float = 1, scrollOneY:Float = 1, scrollTwoX:Float = 1.1, scrollTwoY:Float = 1.1,
			direct:String = 'horizontal'):ParallaxSprite
	{
		pointOne.scrollFactor.set(1, 1);
		pointTwo.scrollFactor.set(1, 1);
		pointOne.setPosition(anchorX + x, anchorY + y);

		switch (direct.toLowerCase())
		{
			case 'horizontal', 'orizzontale', 'horisontell':
				direction = HORIZONTAL;
				pointTwo.setPosition((x + anchorX), (y + anchorY + frameHeight));
			case 'vertical', 'vertikale', 'verticale', 'vertikal':
				direction = VERTICAL;
				pointTwo.setPosition((x + anchorX + frameWidth), (y + anchorY));
		}
		scrollFactor.set(scrollOneX, scrollOneY);
		pointOne.scrollFactor.set(scrollOneX, scrollOneY);
		pointTwo.scrollFactor.set(scrollTwoX, scrollTwoY);
		return this;
	}

	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
	{
		if (newRect == null)
			newRect = FlxRect.get();

		if (camera == null)
			camera = FlxG.camera;

		newRect.setPosition(x, y);
		if (pixelPerfectPosition)
			newRect.floor();
		newRect.x += -Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x;
		newRect.y += -Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y;
		if (isPixelPerfectRender(camera))
			newRect.floor();
		newRect.setSize(frameWidth * _matrix.a, frameHeight * _matrix.d);
		return newRect.getRotatedBounds(angle, _scaledOrigin, newRect);
	}

	override public function destroy():Void
	{
		pointOne = null;
		pointTwo = null;
		_bufferOne.put();
		_bufferTwo.put();
		direction = null;
		super.destroy();
	}

	@:noCompletion
	override function drawComplex(camera:FlxCamera):Void
	{
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_bufferOne.copyFrom(pointOne.getScreenPosition());
		_bufferTwo.copyFrom(pointTwo.getScreenPosition());

		if (direction == HORIZONTAL)
		{
			_matrix.c = (_bufferTwo.x - _bufferOne.x) / frameHeight;
			_matrix.d = (_bufferTwo.y - _bufferOne.y) / frameHeight;
		}
		else if (direction == VERTICAL)
		{
			_matrix.b = (_bufferTwo.y - _bufferOne.y) / frameWidth;
			_matrix.a = (_bufferTwo.x - _bufferOne.x) / frameWidth;
		}

		if (bakedRotationAngle <= 0)
		{
			updateTrig();

			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		if (isPixelPerfectRender(camera))
			_point.floor();
		_matrix.tx += _point.x;
		_matrix.ty += _point.y;

		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	override public function isSimpleRender(?camera:FlxCamera):Bool
	{
		if (!FlxG.renderBlit)
			return false;
		return super.isSimpleRender(camera) && _matrix.c == 0 && _matrix.b == 0;
	}
}
#end

/*
	Project your visuals with linear transformations that seamlessly integrate with HaxeFlixel's scrollfactors!
	Classic ParallaxSprite class for ParallaxLT
	https://github.com/Itz-Miles/parallaxLT

		Comply with the license!!!

		© 2022 It'z_Miles - some rights rerserved.

		Licensed under the Apache License, Version 2.0 (the "License");
		you may not use this file except in compliance with the License.
		You may obtain a copy of the License at

			http://www.apache.org/licenses/LICENSE-2.0

		Unless required by applicable law or agreed to in writing, software
		distributed under the License is distributed on an "AS IS" BASIS,
		WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		See the License for the specific language governing permissions and
		limitations under the License.
 */
