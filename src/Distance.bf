using System;

namespace RGBeef;

static
{
	public static float DeltaE00(LAB c1, LAB c2, float kL = 1f, float kC = 1f, float kH = 1f)
	{
		const float twentyfiveToSeventh = 6103515625; // 25^7

		mixin DiffAtan(float x, float y)
		{
			x == 0 && y == 0 ? 0 : x >= 0 ? RadToDeg!(Math.Atan2(x, y)) : RadToDeg!(Math.Atan2(x, y)) + 360
		}

		let
			C1 = Math.Sqrt(Math.Pow(c1.a, 2) + Math.Pow(c1.b, 2f)),
			C2 = Math.Sqrt(Math.Pow(c2.a, 2f) + Math.Pow(c2.b, 2f)),
			CM = 0.5f * (C1 + C2),
			CM7 = Math.Pow(CM, 7f),
			G = 0.5f * (1f - Math.Sqrt(CM7 / (CM7 + twentyfiveToSeventh))),
			aa1 = (1f + G) * c1.a, // aa1 is c1.a prime
			aa2 = (1f + G) * c2.a,
			CC1 = Math.Sqrt(Math.Pow(aa1, 2f) + Math.Pow(c1.b, 2f)),
			CC2 = Math.Sqrt(Math.Pow(aa2, 2f) + Math.Pow(c2.b, 2f)),
			h1 = DiffAtan!(c1.b, aa1),
			h2 = DiffAtan!(c2.b, aa2),
			LM = 0.5f * (c1.l + c2.l),
			CCM = 0.5f * (CC1 + CC2);

		var deltah = h2 - h1 + 360f;
		if (CC1 == 0 || CC2 == 0)
			deltah = 0;
		else if (Math.Abs(h2 - h1) <= 180f)
			deltah = h2 - h1;
		else if (h2 - h1 > 180f)
			deltah = h2 - h1 - 360f;

		var hM = 0.5f * (h1 + h2 - 360f);
		if (CC1 == 0 || CC2 == 0)
			hM = h1 + h2;
		else if (Math.Abs(h2 - h1) <= 180f)
			hM = 0.5f * (h1 + h2);
		else if (h2 - h1 > 180f)
			hM = 0.5f * (h1 + h2 + 360f);

		let deltaL = c2.l - c1.l,
			deltaCC = CC2 - CC1,
			deltaHH = 2 * Math.Sqrt(CC1 * CC2) * Math.Sin(DegToRad!(0.5f * deltah)),
			deltaTheta = 30f * Math.Exp(-1 * Math.Pow((hM - 275f) / 25f, 2f)),
			T = 1f - 0.17f * Math.Cos(DegToRad!(hM - 30f)) + 0.24f * Math.Cos(DegToRad!(2f * hM)) +
			0.32f * Math.Cos(DegToRad!(3 * hM + 6f)) - 0.20f * Math.Cos(DegToRad!(4f * hM - 63f)),
			RC = 2f * Math.Sqrt(Math.Pow(CCM, 7f) / (Math.Pow(CCM, 7) + twentyfiveToSeventh)),
			SL = 1f + 0.015f * Math.Pow((LM - 50f), 2f) / Math.Sqrt(20f + Math.Pow((LM - 50f), 2f)),
			SC = 1f + 0.045f * CCM,
			SH = 1f + 0.015f * CCM * T,
			RT = -Math.Sin(DegToRad!(2 * deltaTheta)) * RC;

		return Math.Sqrt(Math.Pow(deltaL / (kL * SL),  2f) +
			Math.Pow(deltaCC / (kC * SC), 2f) +
			Math.Pow(deltaHH / (kH * SH), 2f) +
			RT * (deltaCC / (kC * SC)) * (deltaHH / (kH * SH)));
	}
}
