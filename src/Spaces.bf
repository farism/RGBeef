using System;
using System.Collections;
using System.Reflection;

namespace RGBeef;

[AttributeUsage(.Types)]
struct ColorSpaceAttribute : Attribute, IOnTypeInit
{
	[Comptime]
	public void OnTypeInit(Type type, Self* prev)
	{
		let tostring = scope $"";
		for (var fieldInfo in type.GetFields())
		{
			if (fieldInfo.IsInstanceField)
			{
				if (@fieldInfo.Index > 0)
				{
					tostring.Append(", ");
				}
				tostring.AppendF($"{fieldInfo.Name}=\{this.{fieldInfo.Name}\}");
			}
		}

		Compiler.EmitTypeBody(type, scope $"""
			public override void ToString(String str)
			{{
				 str.AppendF($"{type.ToString(.. scope $"")}({tostring})");
			}}

			static public Result<Self> ParseHex(StringView str)
			{{
				if(let c = Color.ParseHex(str))
					return .Ok(Self(c));
					
				return .Err;
			}}

			static public Result<Self> ParseHexTiny(StringView str)
			{{
				if(let c = Color.ParseHexTiny(str))
					return .Ok(Self(c));
					
				return .Err;
			}}

			static public Result<Self> ParseHtmlHex(StringView str)
			{{
				if(let c = Color.ParseHtmlHex(str))
					return .Ok(Self(c));
					
				return .Err;
			}}

			static public Result<Self> ParseHtmlHexTiny(StringView str)
			{{
				if(let c = Color.ParseHtmlHexTiny(str))
					return .Ok(Self(c));
					
				return .Err;
			}}

			static public Result<Self> ParseHtmlRgb(StringView str)
			{{
				if(let c = Color.ParseHtmlRgb(str))
					return .Ok(Self(c));
					
				return .Err;
			}}

			static public Result<Self> ParseHtmlRgba(StringView str)
			{{
				if(let c = Color.ParseHtmlRgba(str))
					return .Ok(Self(c));
					
				return .Err;
			}}

			static public Result<Self> ParseHtmlName(StringView str)
			{{
				if(let c = Color.ParseHtmlName(str))
					return .Ok(Self(c));

				return .Err;
			}}

			static public Result<Self> ParseHtmlColor(StringView str)
			{{
				return Self(Color.ParseHtmlColor(str));
			}}

			[Inline]
			public void ToHex(String str)
			{{
				color.ToHex(str);
			}}

			[Inline]
			public void ToHtmlHex(String str)
			{{
				color.ToHtmlHex(str);
			}}

			[Inline]
			public void ToHtmlHexTiny(String str)
			{{
				color.ToHtmlHexTiny(str);
			}}

			[Inline]
			public void ToHtmlRgb(String str)
			{{
				color.ToHtmlRgb(str);
			}}

			[Inline]
			public void ToHtmlRgba(String str)
			{{
				color.ToHtmlRgba(str);
			}}

			[Inline]
			public void Lighten(float amount) mut
			{{
				this = Self(color..Lighten(amount));
			}}

			[Inline]
			public void Darken(float amount) mut
			{{
				Lighten(-amount);
			}}

			[Inline]
			public void Saturate(float amount) mut
			{{
				this = Self(color..Saturate(amount));
			}}

			[Inline]
			public void Desaturate(float amount) mut
			{{
				Saturate(-amount);
			}}
			
			[Inline]
			public void Mix(IColorSpace c) mut
			{{
				this = Self(color..Mix(c.color));
			}}

			[Inline]
			public void Mix(IColorSpace c, double lerp) mut
			{{
				this = Self(color..Mix(c.color, lerp));
			}}

			public RGB rgb {{ get => color.rgb; }}

			public RGBA rgba {{ get => color.rgba; }}

			public RGBX rgbx {{ get => RGBX(color.rgba); }}

			public HSL hsl {{ get => color.hsl; }}

			public HSV hsv {{ get => color.hsv; }}

			public CMY cmy {{ get => color.cmy; }}

			public CMYK cmyk {{ get => color.cmyk; }}

			public YUV yuv {{ get => color.yuv; }}

			public XYZ xyz {{ get => color.xyz; }}

			public LUV luv {{ get => color.luv; }}

			public PolarLUV polarluv {{ get => color.polarluv; }}

			public LAB lab {{ get => color.lab; }}

			public PolarLAB polarlab {{ get => color.polarlab; }}

			public Oklab oklab {{ get => color.oklab; }}

			public PolarOklab polaroklab {{ get => color.polaroklab; }}
		""");
	}
}

interface IColorSpace
{
	Color color { get; };
	void Mix(IColorSpace c) mut;
	void Lighten(float amount) mut;
	void Darken(float amount) mut;
	void Saturate(float amount) mut;
	void Desaturate(float amount) mut;
}

[ColorSpace]
struct RGB : IColorSpace
{
	public uint8 r = 0; // 0 to 255
	public uint8 g = 0; // 0 to 255
	public uint8 b = 0; // 0 to 255

	public Color color
	{
		get
		{
			return .(r / 255.0, g / 255.0, b / 255.0, 1);
		}
	}

	public this(uint8 r, uint8 g, uint8 b)
	{
		this.r = r;
		this.b = b;
		this.g = g;
	}

	public this(Color color)
	{
		r = (uint8)Math.Round(color.r * 255.0);
		g = (uint8)Math.Round(color.g * 255.0);
		b = (uint8)Math.Round(color.b * 255.0);
	}
}

[ColorSpace]
struct RGBA : IColorSpace
{
	public uint8 r = 0; // 0 to 255
	public uint8 g = 0; // 0 to 255
	public uint8 b = 0; // 0 to 255
	public uint8 a = 0; // 0 to 255

	public Color color
	{
		get
		{
			return .(r / 255.0, g / 255.0, b / 255.0, a / 255.0);
		}
	}

	public this(uint8 r, uint8 g, uint8 b, uint8 a)
	{
		this.r = r;
		this.b = b;
		this.g = g;
		this.a = a;
	}

	public this(Color color)
	{
		r = (uint8)Math.Round(color.r * 255);
		g = (uint8)Math.Round(color.g * 255);
		b = (uint8)Math.Round(color.b * 255);
		a = (uint8)Math.Round(color.a * 255);
	}

	public this(RGBX color)
	{
		r = color.r;
		g = color.g;
		b = color.b;
		a = color.a;

		if (a != 0 && a != 255)
		{
			r = (uint8)(Math.Round(r * 255.0 / a));
			g = (uint8)(Math.Round(g * 255.0 / a));
			b = (uint8)(Math.Round(b * 255.0 / a));
		}
	}
}

[ColorSpace]
struct RGBX : IColorSpace
{
	public uint8 r = 0; // 0 to 255
	public uint8 g = 0; // 0 to 255
	public uint8 b = 0; // 0 to 255
	public uint8 a = 0; // 0 to 255

	public Color color
	{
		get
		{
			return RGBA(this).color;
		}
	}

	public this(uint8 r, uint8 g, uint8 b, uint8 a)
	{
		this.r = r;
		this.b = b;
		this.g = g;
		this.a = a;
	}

	public this(Color color)
	{
		this = .(color.rgba);
	}

	public this(RGB color)
	{
		r = color.r;
		g = color.g;
		b = color.b;
		a = 255;
	}

	public this(RGBA color)
	{
		r = uint8(Math.Round((int)color.r * (int)color.a / 255f));
		g = uint8(Math.Round((int)color.g * (int)color.a / 255f));
		b = uint8(Math.Round((int)color.b * (int)color.a / 255f));
		a = color.a;
	}
}

[ColorSpace]
struct CMY : IColorSpace
{
	public float c = 0; // 0 to 100
	public float m = 0; // 0 to 100
	public float y = 0; // 0 to 100

	public Color color
	{
		get
		{
			return .(1 - c / 100.0, 1 - m / 100.0, 1 - y / 100.0, 1);
		}
	}

	public this(double c, double m, double y)
	{
		this.c = (float)c;
		this.m = (float)m;
		this.y = (float)y;
	}

	public this(Color color)
	{
		c = float((1.0 - color.r) * 100.0);
		m = float((1.0 - color.g) * 100.0);
		y = float((1.0 - color.b) * 100.0);
	}
}

[ColorSpace]
struct CMYK : IColorSpace
{
	public float c = 0; // 0 to 1
	public float m = 0; // 0 to 1
	public float y = 0; // 0 to 1
	public float k = 0; // 0 to 1

	public Color color
	{
		get
		{
			let
				k = this.k / 100.0,
				c = this.c / 100.0,
				m = this.m / 100.0,
				y = this.y / 100.0,
				r = 1 - Math.Min(1.0, c * (1.0 - k) + k),
				g = 1 - Math.Min(1.0, m * (1.0 - k) + k),
				b = 1 - Math.Min(1.0, y * (1.0 - k) + k);

			return .(r, g, b, 1.0);
		}
	}

	public this(double c, double m, double y, double k)
	{
		this.c = (float)c;
		this.m = (float)m;
		this.y = (float)y;
		this.k = (float)k;
	}

	public this(Color color)
	{
		mixin t(float a, float k) => ((1.0 - a - k) / (1.0 - k) * 100.0);

		let k = 1 - Math.Max3(color.r, color.g, color.b);
		if (k != 1.0)
		{
			c = (float)t!(color.r, k);
			m = (float)t!(color.g, k);
			y = (float)t!(color.b, k);
		}

		this.k = float(k * 100.0);
	}
}

[ColorSpace]
struct HSL : IColorSpace
{
	public float h = 0; // 0 to 360
	public float s = 0; // 0 to 100
	public float l = 0; // 0 to 100

	public Color color
	{
		get
		{
			let
				h = h / 360.0,
				s = s / 100.0,
				l = l / 100.0;

			var t1 = 0.0,
				t2 = 0.0,
				t3 = 0.0;

			if (s == 0.0)
				return Color(l, l, l);
			if (l < 0.5)
				t2 = l * (1 + s);
			else
				t2 = l + s - l * s;

			t1 = 2.0 * l - t2;

			double[3] rgb = .();

			for (let i in 0 ... 2)
			{
				t3 = h + 1.0 / 3.0 * -(i - 1.0);
				if (t3 < 0)
					t3 += 1;
				else if (t3 > 1)
					t3 -= 1;

				double val;

				if (6.0 * t3 < 1)
					val = t1 + (t2 - t1) * 6.0 * t3;
				else if (2.0 * t3 < 1)
					val = t2;
				else if (3.0 * t3 < 2)
					val = t1 + (t2 - t1) * (2.0 / 3.0 - t3) * 6.0;
				else
					val = t1;

				rgb[i] = val;
			}

			return .(rgb[0], rgb[1], rgb[2], 1.0);
		}
	}

	public this(double h, double s, double l)
	{
		this.h = (float)h;
		this.s = (float)s;
		this.l = (float)l;
	}

	public this(Color color)
	{
		let
			min = Math.Min3(color.r, color.g, color.b),
			max = Math.Max3(color.r, color.g, color.b),
			delta = max - min;

		if (max == min)
			h = 0;
		else if (color.r == max)
			h = (color.g - color.b) / delta;
		else if (color.g == max)
			h = 2 + (color.b - color.r) / delta;
		else if (color.b == max)
			h = 4 + (color.r - color.g) / delta;

		h = (float)Math.Min(h * 60.0, 360.0);
		if (h < 0)
			h += 360;

		l = float((min + max) / 2.0);

		if (max == min)
			s = 0;
		else if (l <= 0.5)
			s = delta / (max + min);
		else
			s = float(delta / (2.0 - max - min));

		s *= 100;
		l *= 100;
	}
}

[ColorSpace]
struct HSV : IColorSpace
{
	public float h = 0; // 0 to 360
	public float s = 0; // 0 to 100
	public float v = 0; // 0 to 100

	public Color color
	{
		get
		{
			let
				h = h / 60.0,
				s = s / 100.0,
				v = v / 100.0,
				f = h - Math.Floor(h),
				p = v * (1 - s),
				q = v * (1 - (s * f)),
				t = v * (1 - (s * (1 - f))),
				hi = Math.Floor(h) % 6;

			switch (hi) {
				case 0:
					return Color(v, t, p, 1);
				case 0:
					return Color(v, t, p, 1);
				case 1:
					return Color(q, v, p, 1);
				case 2:
					return Color(p, v, t, 1);
				case 3:
					return Color(p, q, v, 1);
				case 4:
					return Color(t, p, v, 1);
				case 5:
					return Color(v, p, q, 1);
				default:
					return Color();
			}
		}
	}

	public this(double h, double s, double v)
	{
		this.h = (float)h;
		this.s = (float)s;
		this.v = (float)v;
	}

	public this(Color color)
	{
		let
			min = Math.Min(color.r, Math.Min(color.g, color.b)),
			max = Math.Max(color.r, Math.Max(color.g, color.b)),
			delta = max - min;

		if (max == min)
			h = 0;
		else if (color.r == max)
			h = (color.g - color.b) / delta;
		else if (color.g == max)
			h = 2 + (color.b - color.r) / delta;
		else if (color.b == max)
			h = 4 + (color.r - color.g) / delta;

		h = (float)Math.Min(h * 60.0, 360.0);
		if (h < 0)
			h += 360;

		if (max == min)
			s = 0;
		else
			s = float(delta / max * 100.0);

		v = float(max * 100.0);
	}
}

[ColorSpace]
struct YUV : IColorSpace
{
	public float y = 0; // 0 to 1
	public float u = 0; // -0.5 to 0.5
	public float v = 0; // -0.5 to 0.5

	public Color color
	{
		get
		{
			let r = Math.Clamp((y * 1.0) + (u * +0.00000) + (v * +1.13983), 0, 1),
				g = Math.Clamp((y * 1.0) + (u * -0.39465) + (v * -0.58060), 0, 1),
				b = Math.Clamp((y * 1.0) + (u * +2.02311) + (v * +0000000), 0, 1);

			return .(r, g, b, 1);
		}
	}

	public this(double y, double u, double v)
	{
		this.y = (float)y;
		this.u = (float)u;
		this.v = (float)v;
	}

	public this(Color color)
	{
		y = float((color.r * +0.29900) + (color.g * +0.58700) + (color.b * +0.11400));
		u = float((color.r * -0.14713) + (color.g * -0.28886) + (color.b * +0.43600));
		v = float((color.r * +0.61500) + (color.g * -0.51499) + (color.b * -0.10001));
	}
}

[ColorSpace]
struct XYZ : IColorSpace
{
	public float x = 0; // 0.0 to WhiteX
	public float y = 0; // 0.0 to WhiteY
	public float z = 0; // 0.0 to WhiteZ

	public static double Epsilon = 216.0 / 24389.0;
	public static double Kappa = 24389.0 / 27.0;
	public static double WhiteX = 95.047;
	public static double WhiteY = 100.000;
	public static double WhiteZ = 108.883;

	public Color color
	{
		get
		{
			let r = GTrans((x * +3.240479 - y * 1.537150 - z * 0.498535) / WhiteY),
				g = GTrans((x * -0.969256 + y * 1.875992 + z * 0.041556) / WhiteY),
				b = GTrans((x * +0.055648 - y * 0.204043 + z * 1.057311) / WhiteY),
				result = Color(r, g, b, 1);

			return result;
		}
	}

	public this(double x, double y, double z)
	{
		this.x = (float)x;
		this.y = (float)y;
		this.z = (float)z;
	}

	public this(Color color)
	{
		let r = FTrans(color.r, 2.4),
			g = FTrans(color.g, 2.4),
			b = FTrans(color.b, 2.4);

		x = float(WhiteY * (r * 0.412453 + g * 0.357580 + b * 0.180423));
		y = float(WhiteY * (r * 0.212671 + g * 0.715160 + b * 0.072169));
		z = float(WhiteY * (r * 0.019334 + g * 0.119193 + b * 0.950227));
	}

	public this(LUV color)
	{
		if (color.l <= 0 && color.u == 0 && color.v == 0)
			return;

		if (color.l > 8)
			y = float(WhiteY * Math.Pow((color.l + 16.0) / 116.0, 3.0));
		else
			y = float(WhiteY * color.l / Kappa);

		let (uN, vN) = XYZ.UV(White()),
			u = color.l == 0 ? uN : color.u / (13.0 * color.l) + uN,
			v = color.l == 0 ? vN : color.v / (13.0 * color.l) + vN;

		x = float(9.0 * y * u / (4.0 * v));
		z = float(-x / 3.0 - y * 5.0 + (y / v) * 3.0);
	}

	public this(LAB color)
	{
		if (color.l <= 0)
			y = 0;
		else if (color.l <= 8)
			y = float(color.l * WhiteY / Kappa);
		else if (color.l <= 100)
			y = float(WhiteY * Math.Pow((color.l + 16.0) / 116.0, 3));
		else
			y = float(WhiteY);

		double fy;
		if (y <= Epsilon * WhiteY)
			fy = (Kappa / 116.0) * y / WhiteY + 16.0 / 116.0;
		else
			fy = Math.Cbrt(float(y / WhiteY));

		let fx = float(fy + (color.a / 500.0));
		if (Math.Pow(fx, 3) <= Epsilon)
			x = float(WhiteX * (fx - 16.0 / 116.0) / (Kappa / 116.0));
		else
			x = float(WhiteX * Math.Pow(fx, 3));

		let fz = fy - (color.b / 200.0);
		if (Math.Pow(fz, 3) <= Epsilon)
			z = float(WhiteZ * (fz - 16.0 / 116.0) / (Kappa / 116.0));
		else
			z = float(WhiteZ * Math.Pow(fz, 3));
	}

	public static XYZ White()
	{
		return XYZ(WhiteX, WhiteY, WhiteZ);
	}

	public static (double, double) UV(XYZ c)
	{
		let t = c.x + c.y + c.z,
			x = t == 0 ? 0 : c.x / t,
			y = t == 0 ? 0 : c.y / t,
			u = 2.0 * x / (6.0 * y - x + 1.5),
			v = 4.5 * y / (6.0 * y - x + 1.5);

		return (u, v);
	}

	double FTrans(double u, double gamma)
	{
		if (u > 0.03928)
			return Math.Pow((u + 0.055) / 1.055, gamma);
		else
			return u / 12.92;
	}

	double GTrans(double u)
	{
		const double GAMMA = 2.4;

		if (u > 0.00304)
			return 1.055 * Math.Pow(u, (1.0 / GAMMA)) - 0.055;
		else
			return 12.92 * u;
	}
}

[ColorSpace]
struct LAB : IColorSpace
{
	public float l = 0; // lightness, range 0.0 (black) to 100.0 (white)
	public float a = 0; // green (min) to red (max)
	public float b = 0; // blue (min) to yellow (max)

	public Color color
	{
		get
		{
			return XYZ(this).color;
		}
	}

	public this(double l, double a, double b)
	{
		this.l = (float)l;
		this.a = (float)a;
		this.b = (float)b;
	}

	public this(Color color)
	{
		let xyz = color.xyz;

		let xr = xyz.x / XYZ.WhiteX,
			yr = xyz.y / XYZ.WhiteY,
			zr = xyz.z / XYZ.WhiteZ,
			xt = F(xr),
			yt = F(yr),
			zt = F(zr);

		if (yr > XYZ.Epsilon)
			l = float(116.0 * Math.Cbrt((float)yr) - 16.0);
		else
			l = float(XYZ.Kappa * yr);

		a = float(500.0 * (xt - yt));
		b = float(200.0 * (yt - zt));
	}

	public this(PolarLAB color)
	{
		l = color.l;
		a = Math.Cos(DegToRad!(color.h)) * color.c;
		b = Math.Sin(DegToRad!(color.h)) * color.c;
	}

	[Inline]
	double F(double t)
	{
		if (t > XYZ.Epsilon)
			return Math.Cbrt((float)t);
		else
			return (XYZ.Kappa / 116.0) * t + 16.0 / 116.0;
	}

}

[ColorSpace]
struct PolarLAB : IColorSpace
{
	public float l = 0; // lightness, range 0.0 (black) to 100.0 (white)
	public float c = 0; // chroma, range 0.0 to max
	public float h = 0; // hue angle, range 0.0 to 360.0
				 // (red: 0, yellow: 90, green: 180, blue: 270)
	public Color color
	{
		get
		{
			return LAB(this).color;
		}
	}

	public this(double l, double c, double h)
	{
		this.l = (float)l;
		this.c = (float)c;
		this.h = (float)h;
	}

	public this(Color color)
	{
		let lab = color.lab;

		l = lab.l;
		c = Math.Sqrt(lab.a * lab.a + lab.b * lab.b);
		h = RadToDeg!(Math.Atan2(lab.b, lab.a));
		while (h > 360)
			h = h - 360;
		while (h < 0)
			h = h + 360;
	}
}

[ColorSpace]
struct LUV : IColorSpace
{
	public float l = 0; // lightness, range 0.0 to 100.0
	public float u = 0; // red to green
	public float v = 0; // blue to yellow

	public Color color
	{
		get
		{
			return XYZ(this).color;
		}
	}

	public this(double l, double u, double v)
	{
		this.l = (float)l;
		this.u = (float)u;
		this.v = (float)v;
	}

	public this(Color color)
	{
		let xyz = color.xyz,
			(u, v) = XYZ.UV(xyz),
			(uN, vN) = XYZ.UV(XYZ.White()),
			y = xyz.y / XYZ.WhiteY;

		if (y > XYZ.Epsilon)
			l = float(116.0 * Math.Cbrt((float)y) - 16.0);
		else
			l = float(XYZ.Kappa * y);

		this.u = (float)(13.0 * l * (u - uN));
		this.v = (float)(13.0 * l * (v - vN));
	}

	public this(PolarLUV color)
	{
		let hrad = DegToRad!(color.h);
		l = color.l;
		u = color.c * Math.Cos(hrad);
		v = color.c * Math.Sin(hrad);
	}
}

[ColorSpace]
struct PolarLUV : IColorSpace
{
	public float h = 0; // hue angle, range 0.0 to 360.0
	public float c = 0; // chroma
	public float l = 0; // luminance

	public Color color
	{
		get
		{
			return LUV(this).color;
		}
	}

	public this(double h, double c, double l)
	{
		this.h = (float)h;
		this.c = (float)c;
		this.l = (float)l;
	}

	public this(Color color)
	{
		let luv = color.luv;

		l = luv.l;
		c = Math.Sqrt(luv.u * luv.u + luv.v * luv.v);
		h = RadToDeg!(Math.Atan2(luv.v, luv.u));
		while (h > 360.0)
			h = h - 360;
		while (h < 0.0)
			h = h + 360;
	}
}

[ColorSpace]
struct Oklab : IColorSpace
{
	public float L; // perceived lightness
	public float a; // greenless/redness
	public float b; // blueless/yellowless

	public Color color
	{
		get
		{
			let
				l = Math.Pow(L + 0.3963377774 * a + 0.2158037573 * b, 3),
				m = Math.Pow(L - 0.1055613458 * a - 0.0638541728 * b, 3),
				s = Math.Pow(L - 0.0894841775 * a - 1.2914855480 * b, 3),
				r = +4.0767245293 * l - 3.3072168827 * m + 0.2307590544 * s,
				g = -1.2681437731 * l + 2.6093323231 * m - 0.3411344290 * s,
				b = -0.0041119885 * l - 0.7034763098 * m + 1.7068625689 * s,
				a = 1.0;

			return Color(r, g, b, a);
		}
	}

	public this(double L, double a, double b)
	{
		this.L = (float)L;
		this.a = (float)a;
		this.b = (float)b;
	}

	public this(Color color)
	{
		let
			l = Math.Cbrt((float)(0.4121656120 * color.r + 0.5362752080 * color.g + 0.0514575653 * color.b)),
			m = Math.Cbrt((float)(0.2118591070 * color.r + 0.6807189584 * color.g + 0.1074065790 * color.b)),
			s = Math.Cbrt((float)(0.0883097947 * color.r + 0.2818474174 * color.g + 0.6302613616 * color.b));

		L = (float)(l * 0.2104542553 + m * +0.7936177850 + s * -0.0040720468);
		a = (float)(l * 1.9779984951 + m * -2.4285922050 + s * +0.4505937099);
		b = (float)(l * 0.0259040371 + m * +0.7827717662 + s * -0.8086757660);
	}

	public this(PolarOklab color)
	{
		let hrad = DegToRad!(color.h);
		L = color.L;
		a = color.C * Math.Cos(hrad);
		b = color.C * Math.Sin(hrad);
	}
}

[ColorSpace]
struct PolarOklab : IColorSpace
{
	public float L = 0; // perceived lightness
	public float C = 0; // chroma
	public float h = 0; // hue

	public this(double L, double C, double h)
	{
		this.L = (float)L;
		this.C = (float)C;
		this.h = (float)h;
	}

	public Color color
	{
		get
		{
			return Oklab(this).color;
		}
	}

	public this(Color color)
	{
		let lab = color.oklab;

		L = lab.L;
		C = Math.Sqrt(lab.a * lab.a + lab.b * lab.b);
		h = RadToDeg!(Math.Atan2(lab.b, lab.a));
		while (h > 360.0)
			h = h - 360;
		while (h < 0.0)
			h = h + 360;
	}
}


typealias ColorHCL = PolarLUV;