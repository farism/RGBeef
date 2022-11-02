using System;
using System.Reflection;
using System.Collections;
using System.Diagnostics;

namespace RGBeef.Tests;

static
{
	static Color[?] colors = .(
		Color(1, 0, 0),
		Color(0, 1, 0),
		Color(0, 0, 1),
		Color(1, 1, 1),
		Color(0, 0, 0),
		Color(0.5, 0.5, 0.5),
		Color(0.1, 0.2, 0.3),
		Color(0.6, 0.5, 0.4),
		Color(0.7, 0.8, 0.9),
		Color(0.001, 0.001, 0.001),
		Color(0.999, 0.999, 0.999),
		Color(0.01, 0, 0),
		Color(0, 0.01, 0),
		Color(0, 0, 0.01)
		);

	static Color[?] colorsAlpha = .(
		Color(0, 0, 0, 0),
		Color(0, 0, 0, 0.25),
		Color(0, 0, 0, 0.5),
		Color(0, 0, 0, 0.75),
		Color(0, 0, 0, 1.0)
		);

	static Color[?] colorsRSpace = .(
		Color.ParseHex("023FA5").Value,
		Color.ParseHex("6371AF").Value,
		Color.ParseHex("959CC3").Value,
		Color.ParseHex("BEC1D4").Value,
		Color.ParseHex("DBDCE0").Value,
		Color.ParseHex("E0DBDC").Value,
		Color.ParseHex("D6BCC0").Value,
		Color.ParseHex("C6909A").Value,
		Color.ParseHex("AE5A6D").Value,
		Color.ParseHex("8E063B").Value
		);

	public static bool AlmostEqual(Color a, Color b, double ep = 0.01)
	{
		return Math.Abs(a.r - b.r) < ep
			&& Math.Abs(a.g - b.g) < ep
			&& Math.Abs(a.b - b.b) < ep;
	}

	public static bool AlmostEqual(IColorSpace a, IColorSpace b, float ep = 0.01f)
	{
		return AlmostEqual(a.color, b.color, ep);
	}

	[Test]
	static void Hex()
	{
		for (let c in colors)
			Test.Assert(AlmostEqual(c, Color.ParseHex(c.ToHex(.. scope $"")).Value));
	}

	[Test]
	static void HexAlpha()
	{
		for (let c in colorsAlpha)
			Test.Assert(AlmostEqual(c, Color.ParseHexAlpha(c.ToHexAlpha(.. scope $"")).Value));
	}

	[Test]
	static void HexTiny()
	{
		for (let c in colors)
			Test.Assert(AlmostEqual(c, Color.ParseHexTiny(c.ToHexTiny(.. scope $"")).Value, 0.1));
	}

	[Test]
	static void HtmlHex()
	{
		for (let c in colors)
			Test.Assert(AlmostEqual(c, Color.ParseHtmlHex(c.ToHtmlHex(.. scope $"")).Value, 0.1));
	}

	[Test]
	static void HtmlHexTiny()
	{
		for (let c in colors)
			Test.Assert(AlmostEqual(c, Color.ParseHtmlHexTiny(c.ToHtmlHexTiny(.. scope $"")).Value, 0.1));
	}

	[Test]
	static void HtmlRgb()
	{
		for (let c in colors)
			Test.Assert(AlmostEqual(c, Color.ParseHtmlRgb(c.ToHtmlRgb(.. scope $"")).Value, 0.1));
	}

	[Test]
	static void HtmlRgba()
	{
		for (let c in colorsAlpha)
			Test.Assert(AlmostEqual(c, Color.ParseHtmlRgba(c.ToHtmlRgba(.. scope $"")).Value, 0.1));
	}

	[Test]
	static void HtmlName()
	{
		Test.Assert(Color.ParseHtmlName("red").Value.ToHex(.. scope $"") == "FF0000");
		Test.Assert(Color.ParseHtmlName("green").Value.ToHex(.. scope $"") == "008000");
		Test.Assert(Color.ParseHtmlName("blue").Value.ToHex(.. scope $"") == "0000FF");
		Test.Assert(Color.ParseHtmlName("white").Value.ToHex(.. scope $"") == "FFFFFF");
		Test.Assert(Color.ParseHtmlName("black").Value.ToHex(.. scope $"") == "000000");
	}

	[Test]
	static void HtmlColor()
	{
		Test.Assert(Color.ParseHtmlColor("#f00").Value.ToHex(.. scope $"") == "FF0000");
		Test.Assert(Color.ParseHtmlColor("#008000").Value.ToHex(.. scope $"") == "008000");
		Test.Assert(Color.ParseHtmlColor("rgb(0,0,255)").Value.ToHex(.. scope $"") == "0000FF");
		Test.Assert(Color.ParseHtmlColor("rgba(255,255,255,255)").Value.ToHex(.. scope $"") == "FFFFFF");
		Test.Assert(Color.ParseHtmlColor("black").Value.ToHex(.. scope $"") == "000000");
	}

	[Test]
	static void RGBColorSpace()
	{
		for (let c in colors)
			Test.Assert(AlmostEqual(c.rgb.color, c));
	}

	[Test]
	static void RGBAColorSpace()
	{
		for (let c in colors)
			Test.Assert(AlmostEqual(c.rgba.color, c));
	}

	[Test]
	static void CMYColorSpace()
	{
		for (let c in colors)
			Test.Assert(AlmostEqual(c.cmy.color, c));
	}

	[Test]
	static void CMYKColorSpace()
	{
		for (let c in colors)
			Test.Assert(AlmostEqual(c.cmyk.color, c));
	}

	[Test]
	static void HSLColorSpace()
	{
		let arr = HSL[?](
			HSL(217.5460, 97.604790, 32.74510),
			HSL(228.9474, 32.203390, 53.72549),
			HSL(230.8696, 27.710843, 67.45098),
			HSL(231.8182, 20.370370, 78.82353),
			HSL(228.0000, 07.462687, 86.86275),
			HSL(348.0000, 07.462687, 86.86275),
			HSL(350.7692, 24.074074, 78.82353),
			HSL(348.8889, 32.142857, 67.05882),
			HSL(346.4286, 34.146341, 51.76471),
			HSL(336.6176, 91.891892, 29.01961)
			);

		for (let i in 0 ..< arr.Count)
			Test.Assert(AlmostEqual(arr[i], colorsRSpace[i].hsl));

		for (let c in colors)
			Test.Assert(AlmostEqual(c.hsl.color, c));
	}

	[Test]
	static void YUVColorSpace()
	{
		for (let c in colors)
			Test.Assert(AlmostEqual(c.yuv.color, c));
	}

	[Test]
	static void HSVColorSpace()
	{
		let arr = HSV[?](
			HSV(217.5460, 98.787879, 64.70588),
			HSV(228.9474, 43.428571, 68.62745),
			HSV(230.8696, 23.589744, 76.47059),
			HSV(231.8182, 10.377358, 83.13725),
			HSV(228.0000, 02.232143, 87.84314),
			HSV(348.0000, 02.232143, 87.84314),
			HSV(350.7692, 12.149533, 83.92157),
			HSV(348.8889, 27.272727, 77.64706),
			HSV(346.4286, 48.275862, 68.23529),
			HSV(336.6176, 95.774648, 55.68627)
			);

		for (let i in 0 ..< arr.Count)
			Test.Assert(AlmostEqual(arr[i], colorsRSpace[i].hsv));

		for (let c in colors)
			Test.Assert(AlmostEqual(c.hsv.color, c));
	}

	[Test]
	static void XYZColorSpace()
	{
		let arr = XYZ[](
			XYZ(8.591080, 6.2831710, 36.347084),
			XYZ(18.78561, 17.556945, 42.944822),
			XYZ(34.12995, 34.105738, 56.399873),
			XYZ(52.18543, 53.840026, 69.912376),
			XYZ(68.25775, 71.628143, 80.730460),
			XYZ(68.98728, 71.677877, 77.891637),
			XYZ(55.22770, 54.069481, 57.382059),
			XYZ(39.09464, 34.287270, 35.121978),
			XYZ(23.87290, 17.417248, 16.568451),
			XYZ(12.01096, 6.1985770, 4.700508));

		for (let i in 0 ..< arr.Count)
			Test.Assert(AlmostEqual(arr[i], colorsRSpace[i].xyz));

		for (let c in colors)
			Test.Assert(AlmostEqual(c.xyz.color, c));
	}

	[Test]
	static void LABColorSpace()
	{
		let arr = LAB[?](
			LAB(30.11593, 25.6159718, -59.2291843),
			LAB(48.95426, 11.2745425, -34.6817925),
			LAB(65.04641, 6.04971110, -20.8859330),
			LAB(78.36836, 2.66412480, -9.83786240),
			LAB(87.78929, 0.38811870, -2.07122820),
			LAB(87.81331, 1.87414180, +0.11733510),
			LAB(78.50223, 9.89344160, +1.38672080),
			LAB(65.18995, 21.8891638, +2.81989480),
			LAB(48.78153, 36.2399176, +4.91703230),
			LAB(29.90803, 53.0297042, +8.99145520)
			);

		for (let i in 0 ..< arr.Count)
			Test.Assert(AlmostEqual(arr[i], colorsRSpace[i].lab));

		for (let c in colors)
			Test.Assert(AlmostEqual(c.lab.color, c));
	}

	[Test]
	static void PolarLABColorSpace()
	{
		let arr = PolarLAB[?](
			PolarLAB(30.11593, 64.531188, 293.387952),
			PolarLAB(48.95426, 36.468370, 288.008584),
			PolarLAB(65.04641, 21.744452, 286.153914),
			PolarLAB(78.36836, 10.192208, 285.152461),
			PolarLAB(87.78929, 2.1072780, 280.613332),
			PolarLAB(87.81331, 1.8778110, 3.58246200),
			PolarLAB(78.50223, 9.9901540, 7.97891900),
			PolarLAB(65.18995, 22.070054, 7.34075900),
			PolarLAB(48.78153, 36.571968, 7.72670900),
			PolarLAB(29.90803, 53.786576, 9.62326700)
			);

		for (let i in 0 ..< arr.Count)
			Test.Assert(AlmostEqual(arr[i], colorsRSpace[i].polarlab));

		for (let c in colors)
			Test.Assert(AlmostEqual(c.polarlab.color, c));
	}

	[Test]
	static void OklabColorSpace()
	{
		let arr = Oklab[?](
			Oklab(0.6059127, -0.0618687, -0.132093335),
			Oklab(0.7673618, +0.0031948, -0.056107075),
			Oklab(0.8522680, +0.0036528, -0.029817891),
			Oklab(0.9129040, +0.0019834, -0.012930225),
			Oklab(0.9521403, +0.0002312, -0.002724297),
			Oklab(0.9524956, +0.0026390, +0.000340000),
			Oklab(0.9144257, +0.0145511, +0.001537969),
			Oklab(0.8536680, +0.0347748, +0.002470664),
			Oklab(0.7624759, +0.0678392, +0.001605107),
			Oklab(0.5607032, +0.2017071, -0.033859189)
			);

		for (let i in 0 ..< arr.Count)
			Test.Assert(AlmostEqual(arr[i], colorsRSpace[i].oklab));

		for (let c in colors)
			Test.Assert(AlmostEqual(c.oklab.color, c));
	}

	[Test]
	static void PolarOklabColorSpace()
	{
		let arr = PolarOklab[?](
			PolarOklab(0.60591274, 0.14580541, 244.8921356),
			PolarOklab(0.76736181, 0.05619394, 273.2592468),
			PolarOklab(0.85226809, 0.03002440, 276.9880981),
			PolarOklab(0.91290402, 0.01315032, 278.6747741),
			PolarOklab(0.95214039, 0.00271021, 274.8944396),
			PolarOklab(0.95249563, 0.00263925, 0.747932300),
			PolarOklab(0.91442573, 0.01463048, 5.967745700),
			PolarOklab(0.85366809, 0.03486439, 4.106989800),
			PolarOklab(0.76247590, 0.06785918, 1.389290000),
			PolarOklab(0.56070321, 0.20453040, 350.4690856)
			);

		for (let i in 0 ..< arr.Count)
			Test.Assert(AlmostEqual(arr[i], colorsRSpace[i].polaroklab));

		for (let c in colors)
			Test.Assert(AlmostEqual(c.polaroklab.color, c));
	}

	[Test]
	static void LUVColorSpace()
	{
		let arr = LUV[?](
			LUV(30.11593, -13.9580496, -78.86780920),
			LUV(48.95426, -9.54610940, -53.36486065),
			LUV(65.04641, -5.81820310, -32.96385756),
			LUV(78.36836, -2.71721010, -15.56125899),
			LUV(87.78929, -0.78429120, -3.240497020),
			LUV(87.81331, +2.78336220, -0.154998770),
			LUV(78.50223, +15.2042643, +0.292252240),
			LUV(65.18995, +33.5088794, +0.076799830),
			LUV(48.78153, +55.3929249, -0.115678900),
			LUV(29.90803, +79.9308245, +0.040768980)
			);

		for (let i in 0 ..< arr.Count)
			Test.Assert(AlmostEqual(arr[i], colorsRSpace[i].luv));

		for (let c in colors)
			Test.Assert(AlmostEqual(c.luv.color, c));
	}

	[Test]
	static void PolarLUVColorSpace()
	{
		let arr = PolarLUV[?](
			PolarLUV(259.9636996, 80.093436, 30.11593),
			PolarLUV(259.8579844, 54.211960, 48.95426),
			PolarLUV(259.9902473, 33.473383, 65.04641),
			PolarLUV(260.0952278, 15.796709, 78.36836),
			PolarLUV(256.3944472, 3.3340570, 87.78929),
			PolarLUV(356.8126275, 2.7876750, 87.81331),
			PolarLUV(1.101188300, 15.207073, 78.50223),
			PolarLUV(0.131317400, 33.508967, 65.18995),
			PolarLUV(359.8803475, 55.393046, 48.78153),
			PolarLUV(0.029223900, 79.930835, 29.90803)
			);

		for (let i in 0 ..< arr.Count)
			Test.Assert(AlmostEqual(arr[i], colorsRSpace[i].polarluv));

		for (let c in colors)
			Test.Assert(AlmostEqual(c.polarluv.color, c));
	}

	[Test]
	static void RGBXPremultiplied()
	{
		for (let a in 0 ... 255)
			for (let r in 0 ... 255)
			{
				let rgbx1 = RGBA((uint8)r, 0, 0, (uint8)a).rgbx,
					rgbx2 = RGBX((uint8)Math.Round(r * a / 255.0), 0, 0, (uint8)a);

				Test.Assert(rgbx1 == rgbx2);
			}
	}

	[Test]
	static void Functions()
	{
		Test.Assert(Color(0.7, 0.8, 0.9)..Darken(0.2).ToHex(.. scope $"") == "6599CB");
		Test.Assert(Color(0.1, 0.8, 0.9)..Lighten(0.2).ToHex(.. scope $"") == "75E0EF");
		Test.Assert(Color.ParseHex("6598CC").Value..Saturate(0.2).ToHex(.. scope $"") == "5097E0");
		Test.Assert(Color.ParseHex("75E0EF").Value..Desaturate(0.2).ToHex(.. scope $"") == "84D4DF");
		Test.Assert(Color.ParseHex("75E0EF").Value..Spin(180.0).ToHex(.. scope $"") == "EF8475");
		Test.Assert(Color.ParseHex("FFFFFF").Value..Mix(Color.ParseHex("000000").Value).ToHex(.. scope $"") == "7F7F7F");
		Test.Assert(Color.ParseHex("FF0000").Value..Mix(Color.ParseHex("00FF00").Value).ToHex(.. scope $"") == "7F7F00");
		Test.Assert(
			AlmostEqual(
			RGB(255, 168, 85)..Mix(RGB(255, 63, 63), 0.06756756454706192).color,
			Color(1.0, 0.6310015916824341, 0.3275039792060852, 1.0)
			));
	}

	[Test]
	static void ColorProximity()
	{
		bool AlmostEqual(double x, double y, double ep = 0.0001) => Math.Abs(x - y) < ep;

		let
			c0 = Color.ParseHex("000003").Value,
			c1 = Color.ParseHex("000001").Value,
			c2 = Color.ParseHex("000002").Value,
			c3 = Color.ParseHex("ffffff").Value,
			res1 = c0.Distance(c1) / 100.0,
			res2 = c0.Distance(c2) / 100.0,
			res3 = c0.Distance(c3) / 100.0,
			expRes1 = 0.00832,
			expRes2 = 0.00412,
			expRes3 = 0.99948;

		Test.Assert(AlmostEqual(res1, expRes1));
		Test.Assert(AlmostEqual(res2, expRes2));
		Test.Assert(AlmostEqual(res3, expRes3));
	}

	[Test]
	static void Temperature()
	{
		Test.Assert(AlmostEqual(Color.FromTemperature(1700), Color(1.0, 0.4728460609912872, 0.0, 1.0))); // Match flame, low pressure sodium lamps (LPS/SOX)
		Test.Assert(AlmostEqual(Color.FromTemperature(1850), Color(1.0, 0.5075678825378418, 0.0, 1.0))); // Candle flame, sunset/sunrise
		Test.Assert(AlmostEqual(Color.FromTemperature(2400), Color(1.0, 0.6151175498962402, 0.2489356100559235, 1.0))); // Standard incandescent lamps
		Test.Assert(AlmostEqual(Color.FromTemperature(2550), Color(1.0, 0.640208899974823, 0.2967877089977264, 1.0))); // Soft white incandescent lamps
		Test.Assert(AlmostEqual(Color.FromTemperature(2700), Color(1.0, 0.6637818813323975, 0.3408890664577484, 1.0))); // "Soft white" compact fluorescent and LED lamps
		Test.Assert(AlmostEqual(Color.FromTemperature(3000), Color(1.0, 0.7068109512329102, 0.4213423728942871, 1.0))); // Warm white compact fluorescent and LED lamps
		Test.Assert(AlmostEqual(Color.FromTemperature(3200), Color(1.0, 0.7327497601509094, 0.4705604314804077, 1.0))); // Studio lamps, photofloods, etc.
		Test.Assert(AlmostEqual(Color.FromTemperature(3350), Color(1.0, 0.7509022951126099, 0.5055340528488159, 1.0))); // Studio "CP" light
		Test.Assert(AlmostEqual(Color.FromTemperature(5000), Color(1.0, 0.8959282636642456, 0.8083687424659729, 1.0))); // Horizon daylight
		Test.Assert(AlmostEqual(Color.FromTemperature(5000), Color(1.0, 0.8959282636642456, 0.8083687424659729, 1.0))); // Tubular fluorescent lamps or cool white
		Test.Assert(AlmostEqual(Color.FromTemperature(5500), Color(1.0, 0.9261417388916016, 0.8775315284729004, 1.0))); // Vertical daylight, electronic flash
		Test.Assert(AlmostEqual(Color.FromTemperature(6200), Color(1.0, 0.9618642926216126, 0.9614840745925903, 1.0))); // Xenon short-arc lamp [2]
		Test.Assert(AlmostEqual(Color.FromTemperature(6500), Color(1.0, 0.9753435850143433, 0.9935365319252014, 1.0))); // Daylight, overcast
		Test.Assert(AlmostEqual(Color.FromTemperature(6500), Color(1.0, 0.9753435850143433, 0.9935365319252014, 1.0))); // LCD or CRT screen
		Test.Assert(AlmostEqual(Color.FromTemperature(15000), Color(0.7009154558181763, 0.7981580495834351, 1.0, 1.0))); // Clear blue poleward sky
	}
}