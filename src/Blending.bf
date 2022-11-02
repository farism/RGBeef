using System;

namespace RGBeef;

static
{
	[Inline]
	public static float Screen(float backdrop, float source)
	{
		return 1 - (1 - backdrop) * (1 - source);
	}

	[Inline]
	public static float HardLight(float backdrop, float source)
	{
		return source <= 0.5 ? backdrop * 2 * source : Screen(backdrop, 2 * source - 1);
	}

	[Inline]
	public static float SoftLight(float backdrop, float source)
	{
		return (1 - 2 * source) * Math.Pow(backdrop, 2) + 2 * source * backdrop;
	}

	[Inline]
	public static float Luminosity(Color color)
	{
		return color.r * 0.3f + color.g * 0.59f + color.b * 0.11f;
	}

	[Inline]
	public static Color SetLuminosity(Color color, float luminosity)
	{
		let d = luminosity - Luminosity(color),
			r = color.r + d,
			g = color.g + d,
			b = color.b + d;

		var result = Color(r, g, b);

		ClipColor(ref result);

		return result;
	}

	[Inline]
	public static float Saturation(Color color)
	{
		return Math.Max3(color.r, color.g, color.b) - Math.Min3(color.r, color.g, color.b);
	}

	[Inline]
	public static Color SetSaturation(Color color, float saturation)
	{
		let satC = Saturation(color);

		if (satC > 0)
			return (color - Math.Min3(color.r, color.g, color.b)) * saturation / satC;

		return .();
	}

	[Inline]
	public static void ClipColor(ref Color color)
	{
		let L = Luminosity(color),
			n = Math.Min3(color.r, color.g, color.b),
			x = Math.Max3(color.r, color.g, color.b);

		if (n < 0)
			color = L + (((color - L) * L) / (L - n));

		if (x > 1)
			color = L + (((color - L) * (1 - L)) / (x - L));
	}

	[Inline]
	public static Color AlphaFix(Color backdrop, Color source, Color mixed)
	{
		let alpha = (source.a + backdrop.a * (1.0f - source.a));

		if (alpha == 0)
		{
			return Color();
		}

		let t0 = source.a * (1 - backdrop.a),
			t1 = source.a * backdrop.a,
			t2 = (1 - source.a) * backdrop.a,
			r = (t0 * source.r + t1 * mixed.r + t2 * backdrop.r) / alpha,
			g = (t0 * source.g + t1 * mixed.g + t2 * backdrop.g) / alpha,
			b = (t0 * source.b + t1 * mixed.b + t2 * backdrop.b) / alpha;

		return .(r, g, b, alpha);
	}

	[Inline]
	public static Color BlendNormal(Color backdrop, Color source)
	{
		return AlphaFix(backdrop, source, source);
	}

	[Inline]
	public static Color BlendDarken(Color backdrop, Color source)
	{
		let r =  Math.Min(backdrop.r, source.r),
			g = Math.Min(backdrop.g, source.g),
			b = Math.Min(backdrop.b, source.b);

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendMultiply(Color backdrop, Color source)
	{
		let r = backdrop.r * source.r,
			g = backdrop.g * source.g,
			b = backdrop.b * source.b;

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendLinearBurn(Color backdrop, Color source)
	{
		let r = backdrop.r + source.r - 1,
			g = backdrop.g + source.g - 1,
			b = backdrop.b + source.b - 1;

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendColorBurn(Color backdrop, Color source)
	{
		mixin Burn(float backdrop, float source)
		{
			backdrop == 1 ? 1 : source == 0 ? 0 : 1 - Math.Min(1, (1 - backdrop) / source)
		}

		let r = Burn!(backdrop.r, source.r),
			g = Burn!(backdrop.g, source.g),
			b = Burn!(backdrop.b, source.b);

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendLighten(Color backdrop, Color source)
	{
		let r = Math.Max(backdrop.r, source.r),
			g = Math.Max(backdrop.g, source.g),
			b = Math.Max(backdrop.b, source.b);

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendScreen(Color backdrop, Color source)
	{
		let r = Screen(backdrop.r, source.r),
			g = Screen(backdrop.g, source.g),
			b = Screen(backdrop.b, source.b);

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendLinearDodge(Color backdrop, Color source)
	{
		let r = backdrop.r + source.r,
			g = backdrop.g + source.g,
			b = backdrop.b + source.b;

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendColorDodge(Color backdrop, Color source)
	{
		mixin Dodge(float backdrop, float source)
		{
			backdrop == 0 ? 0 : source == 1 ? 1 : 1 - Math.Min(1, backdrop / (1 - source))
		}

		let r = Dodge!(backdrop.r, source.r),
			g = Dodge!(backdrop.g, source.g),
			b = Dodge!(backdrop.b, source.b);

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendOverlay(Color backdrop, Color source)
	{
		let r = HardLight(source.r, backdrop.r),
			g = HardLight(source.g, backdrop.g),
			b = HardLight(source.b, backdrop.b);

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendHardLight(Color backdrop, Color source)
	{
		let r = HardLight(backdrop.r, source.r),
			g = HardLight(backdrop.g, source.g),
			b = HardLight(backdrop.b, source.b);

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendSoftLight(Color backdrop, Color source)
	{
		let r = SoftLight(backdrop.r, source.r),
			g = SoftLight(backdrop.g, source.g),
			b = SoftLight(backdrop.b, source.b);

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendDifference(Color backdrop, Color source)
	{
		let r = Math.Abs(backdrop.r - source.r),
			g = Math.Abs(backdrop.g - source.g),
			b = Math.Abs(backdrop.b - source.b);

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendExclusion(Color backdrop, Color source)
	{
		mixin Blend(float backdrop, float source)
		{
			backdrop + source - 2 * backdrop * source
		}

		let r = Blend!(backdrop.r, source.r),
			g = Blend!(backdrop.g, source.g),
			b = Blend!(backdrop.b, source.b);

		return AlphaFix(backdrop, source, .(r, g, b));
	}

	[Inline]
	public static Color BlendColor(Color backdrop, Color source)
	{
		let result = SetLuminosity(source, Luminosity(backdrop));

		return AlphaFix(backdrop, source, result);
	}

	[Inline]
	public static Color BlendLuminosity(Color backdrop, Color source)
	{
		let result = SetLuminosity(backdrop, Luminosity(source));

		return AlphaFix(backdrop, source, result);
	}

	[Inline]
	public static Color BlendHue(Color backdrop, Color source)
	{
		let result = SetLuminosity(SetSaturation(source, Saturation(backdrop)), Luminosity(backdrop));

		return AlphaFix(backdrop, source, result);
	}

	[Inline]
	public static Color BlendSaturation(Color backdrop, Color source)
	{
		let result = SetLuminosity(SetSaturation(backdrop, Saturation(source)), Luminosity(backdrop));

		return AlphaFix(backdrop, source, result);
	}
}
