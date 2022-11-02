using System;
using System.Diagnostics;
using System.Security.Cryptography;

namespace RGBeef;

struct Color
{
	public float r = 0; // 0 to 1
	public float g = 0; // 0 to 1
	public float b = 0; // 0 to 1
	public float a = 0; // 0 to 1, 0 is fully transparent

	public this() { }

	public this(Color color)
	{
		this.r = color.r;
		this.g = color.g;
		this.b = color.b;
		this.a = color.a;
	}

	public this(double r, double g, double b)
	{
		this.r = Math.Clamp((float)r, 0, 1);
		this.g = Math.Clamp((float)g, 0, 1);
		this.b = Math.Clamp((float)b, 0, 1);
		this.a = 1;
	}

	public this(double r, double g, double b, double a)
	{
		this.r = Math.Clamp((float)r, 0, 1);
		this.g = Math.Clamp((float)g, 0, 1);
		this.b = Math.Clamp((float)b, 0, 1);
		this.a = Math.Clamp((float)a, 0, 1);
	}

	public Color Clone()
	{
		return .(this);
	}

	public RGB rgb { get => RGB(this); }

	public RGBA rgba { get => RGBA(this); }

	public RGBX rgbx { get => RGBX(this.rgba); }

	public HSL hsl { get => HSL(this); }

	public HSV hsv { get => HSV(this); }

	public CMY cmy { get => CMY(this); }

	public CMYK cmyk { get => CMYK(this); }

	public YUV yuv { get => YUV(this); }

	public XYZ xyz { get => XYZ(this); }

	public LUV luv { get => LUV(this); }

	public PolarLUV polarluv { get => PolarLUV(this); }

	public LAB lab { get => LAB(this); }

	public PolarLAB polarlab { get => PolarLAB(this); }

	public Oklab oklab { get => Oklab(this); }

	public PolarOklab polaroklab { get => PolarOklab(this); }

	public static Color operator *(Color c, double v)
	{
		return .(c.r + c.r * v, c.g + c.g * v, c.b + c.b * v, c.a + c.a * v);
	}

	public static Color operator /(Color c, double v)
	{
		return .(c.r + c.r / v, c.g + c.g / v, c.b + c.b / v, c.a + c.a / v);
	}

	[Commutable]
	public static Color operator +(Color c, double v)
	{
		return .(c.r + c.r + v, c.g + c.g + v, c.b + c.b + v, c.a + c.a + v);
	}

	[Commutable]
	public static Color operator -(Color c, double v)
	{
		return .(c.r + c.r - v, c.g + c.g - v, c.b + c.b - v, c.a + c.a - v);
	}

	public static Result<Color> ParseHex(StringView str)
	{
		if (str.Length != 6)
			return .Err;

		let r = (C2N(str, 0) * 16 + C2N(str, 1)) / 255.0,
			g = (C2N(str, 2) * 16 + C2N(str, 3)) / 255.0,
			b = (C2N(str, 4) * 16 + C2N(str, 5)) / 255.0;

		return .Ok(Color(r, g, b));
	}

	public static Result<Color> ParseHexAlpha(StringView str)
	{
		if (str.Length != 8)
			return .Err;

		let r = (C2N(str, 0) * 16 + C2N(str, 1)) / 255.0,
			g = (C2N(str, 2) * 16 + C2N(str, 3)) / 255.0,
			b = (C2N(str, 4) * 16 + C2N(str, 5)) / 255.0,
			a = (C2N(str, 6) * 16 + C2N(str, 7)) / 255.0;

		return .Ok(Color(r, g, b, a));
	}

	public static Result<Color> ParseHexTiny(StringView str)
	{
		if (str.Length != 3)
			return .Err;

		let r = C2N(str, 0) / 15.0,
			g = C2N(str, 1) / 15.0,
			b = C2N(str, 2) / 15.0;

		return .Ok(Color(r, g, b));
	}

	static public Result<Color> ParseHtmlHex(StringView str)
	{
		if (!str.StartsWith("#"))
			return .Err;

		return ParseHex(scope String(str[1...]));
	}

	static public Result<Color> ParseHtmlHexTiny(StringView str)
	{
		if (!str.StartsWith("#"))
			return .Err;

		return ParseHexTiny(scope String(str[1...]));
	}

	static public Result<Color> ParseHtmlRgb(StringView str)
	{
		if (str[0 ... 3] != "rgb(" || str[^1] != ')')
			return .Err;

		let arr = scope String(str[4 ... ^2])..Replace(" ", "")..Split!(",");

		if (arr.Count != 3)
			return .Err;

		let r = Math.Min(1.0, Float.Parse(arr[0]) / 255.0),
			g = Math.Min(1.0, Float.Parse(arr[1]) / 255.0),
			b = Math.Min(1.0, Float.Parse(arr[2]) / 255.0);

		return .Ok(Color(r, g, b, 1.0f));
	}

	static public Result<Color> ParseHtmlRgba(StringView str)
	{
		if (str[0 ... 4] != "rgba(" || str[^1] != ')')
			return .Err;

		let arr = scope String(str[5 ... ^2])..Replace(" ", "")..Split!(",");

		if (arr.Count != 4)
			return .Err;

		let r = Math.Min(1.0, Float.Parse(arr[0]) / 255.0),
			g = Math.Min(1.0, Float.Parse(arr[1]) / 255.0),
			b = Math.Min(1.0, Float.Parse(arr[2]) / 255.0),
			a = Math.Min(0.0, Float.Parse(arr[3]));

		return .Ok(Color(r, g, b, a));
	}

	public static Result<Color> ParseHtmlName(StringView str)
	{
		if (let hex = names.GetValue(scope String(str)..ToLower()))
			return ParseHex(hex);

		return .Err;
	}

	public static Result<Color> ParseHtmlColor(StringView str)
	{
		if (str.StartsWith("#") && str.Length == 4)
			return ParseHtmlHexTiny(str);
		if (str.StartsWith("#") && str.Length == 7)
			return ParseHtmlHex(str);
		if (str.Length > 4 && str[0 ... 3] == "rgba")
			return ParseHtmlRgba(str);
		if (str.Length > 3 && str[0 ... 2] == "rgb")
			return ParseHtmlRgb(str);

		return ParseHtmlName(str);
	}

	public void ToHex(String str)
	{
		let r = RGBeef.ToHex(int8(r * 255.0), 2, .. scope $""),
			g = RGBeef.ToHex(int8(g * 255.0), 2, .. scope $""),
			b = RGBeef.ToHex(int8(b * 255.0), 2, .. scope $"");

		str..AppendF($"{r}{g}{b}");
	}

	public void ToHexAlpha(String str)
	{
		let r = RGBeef.ToHex(int8(r * 255.0), 2, .. scope $""),
			g = RGBeef.ToHex(int8(g * 255.0), 2, .. scope $""),
			b = RGBeef.ToHex(int8(b * 255.0), 2, .. scope $""),
			a = RGBeef.ToHex(int8(a * 255.0), 2, .. scope $"");

		str..AppendF($"{r}{g}{b}{a}");
	}

	public void ToHexTiny(String str)
	{
		let r = RGBeef.ToHex(int8(r * 15.0), 2, .. scope $""),
			g = RGBeef.ToHex(int8(g * 15.0), 2, .. scope $""),
			b = RGBeef.ToHex(int8(b * 15.0), 2, .. scope $"");

		str..AppendF($"{r[1...]}{g[1...]}{b[1...]}");
	}

	public void ToHtmlHex(String string)
	{
		ToHex(string..Append("#"));
	}

	public override void ToString(String str)
	{
		str.AppendF($"Color(r={r}, g={g}, b={b}, a={a})");
	}

	public void ToHtmlHexTiny(String string)
	{
		ToHexTiny(string..Append("#"));
	}

	public void ToHtmlRgb(String string)
	{
		let c = rgb;

		string..AppendF($"rgb({c.r}, {c.g}, {c.b})");
	}

	public void ToHtmlRgba(String string)
	{
		let c = rgb;

		string..AppendF($"rgba({c.r}, {c.g}, {c.b}, {a})");
	}

	public void Lighten(double amount) mut
	{
		var hsl = hsl;
		hsl.l += float(100 * amount);
		hsl.l = Math.Clamp(hsl.l, 0, 100);

		var c = hsl.color;
		c.a = this.a;

		this = c;
	}

	public void Darken(double amount) mut
	{
		Lighten(-amount);
	}

	public void Saturate(double amount) mut
	{
		var hsl = hsl;
		hsl.s += float(100 * amount);
		hsl.s = Math.Clamp(hsl.s, 0, 100);

		var c = hsl.color;
		c.a = this.a;

		this = c;
	}

	public void Desaturate(double amount) mut
	{
		Saturate(-amount);
	}

	public void Spin(double degrees) mut
	{
		var hsl = hsl;
		hsl.h += (float)degrees;
		if (hsl.h < 0)
			hsl.h += 360;
		if (hsl.h >= 360)
			hsl.h -= 360;

		var c = hsl.color;
		c.a = this.a;

		this = c;
	}

	public void Mix(Color color) mut
	{
		r = (r + color.r) / 2;
		g = (g + color.g) / 2;
		b = (b + color.b) / 2;
		a = (a + color.a) / 2;
	}

	public void Mix(Color color, double lerp) mut
	{
		mixin lerp(float a, float b, double v)
		{
			a * (1.0f - v) + b * v
		}

		r = (float)lerp!(r, color.r, lerp);
		g = (float)lerp!(g, color.g, lerp);
		b = (float)lerp!(b, color.b, lerp);
		a = (float)lerp!(a, color.a, lerp);
	}

	public float Distance(Color color)
	{
		return DeltaE00(lab, color.lab);
	}

	public static Color FromTemperature(double kelvin)
	{
		mixin SlopeUp(double k, double a, double b, double c, double d, double e)
		{
			a + b * Math.Pow(k + e, 3) * Math.Exp(c * (k + e)) + d * Math.Log(k)
		}

		mixin SlopeDown(double k, double a, double b, double c, double d, double e)
		{
			a + b * Math.Pow(k + e, c) + d * Math.Log(k)
		}

		mixin FromLinear(double v)
		{
			v > 0.0031308 ? 1.055 * Math.Pow(v, 1.0 / 2.4) - 0.055 : v * 12.92
		}

		let temperature = kelvin / 10000;

		var color = Color(0, 0, 0, 1);

		// red
		if (kelvin <= 6600)
			color.r = 1;
		else
			color.r = (float)FromLinear!(SlopeDown!(
				temperature,
				0.32068362618584273,
				0.19668730877673762,
				-1.5139012907556737,
				-0.013883432789258415,
				-0.21298613432655075
				));

		// green
		if (kelvin <= 6600)
			color.g = (float)FromLinear!(SlopeUp!(
				temperature,
				1.226916242502167,
				-1.3109482654223614,
				-5.089297600846147,
				0.6453936305542096,
				-0.44267061967913873
				));
		else
			color.g = (float)FromLinear!(SlopeDown!(
				temperature,
				0.4860175851734596,
				0.1802139719519286,
				-1.397716496795082,
				-0.00803698899233844,
				-0.14573069517701578
				));

		// blue
		if (kelvin >= 6600)
			color.b = 1;
		else if (kelvin <= 1900)
			color.b = 0;
		else
			color.b = (float)FromLinear!(SlopeUp!(
				temperature,
				1.677499032830161,
				-0.02313594016938082,
				-4.221279555918655,
				1.6550275798913296,
				-1.1367244820333684
				));

		return color;
	}
}