using System;

namespace System
{
	extension Math
	{
		[Inline]
		public static float Min3(float a, float b, float c)
		{
			return Math.Min(a, Math.Min(b, c));
		}

		[Inline]
		public static float Max3(float a, float b, float c)
		{
			return Math.Max(a, Math.Max(b, c));
		}

		[Inline]
		public static float Cbrt(float a)
		{
			return Math.Pow(a, 1f / 3f);
		}
	}
}