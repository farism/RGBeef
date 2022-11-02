using System;

namespace RGBeef;

static
{
	const String hexCharsUppercase = "0123456789ABCDEF";


	public static void log<T>(T val)
	{
		Console.WriteLine(" {}", val);
	}

	public static void ToHex(int val, int len, String str)
	{
		str.PadLeft(len, '0');

		var val;
		for (var i = len - 1; i >= 0; i--)
		{
			str[i] = hexCharsUppercase[val & 0xF];
			val = val >> 4;
		}
	}

	[Inline]
	public static void ToHex<T>(T val, String str) where T : var
	{
		ToHex((int)val, sizeof(T) * 2, str);
	}

	public static void ToHex(StringView val, String str)
	{
		for (let char in val.RawChars)
		{
			str.Append(ToHex(char, .. scope String()));
		}
	}

	public static int C2N(StringView hex, int i)
	{
		let c = int(hex[i]);

		if ((int('0') ... int('9')).Contains(c))
			return c - int('0');
		if ((int('a') ... int('f')).Contains(c))
			return 10 + c - int('a');
		if ((int('A') ... int('F')).Contains(c))
			return 10 + c - int('A');

		return 0;
	}

	[Inline]
	public static mixin DegToRad(float degrees)
	{
		degrees * (Math.PI_f / 180f)
	}

	[Inline]
	public static mixin RadToDeg(float radians)
	{
		radians * (180f / Math.PI_f)
	}
}