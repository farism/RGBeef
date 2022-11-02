# RGBeef - Everything you want to do with colors.

[Reference Docs](https://farism.github.io/RGBeef/html/)

## About

Work with colors and color spaces. Easily parse and transform colors. Many different color spaces. Optimized, fast and consistent.

This library has no dependencies other than `Corlib`.

Heavily inspired by [chroma](https://github.com/treeform/chroma)

## Installing

1. Clone this repo somewhere to your system.
2. In the Beef IDE, right-click workspace panel select "Add Existing Project". Locate the directory you just cloned.
3. For each project that will use `RGBeef`, right-click > Properties > Dependencies and check `RGBeef` as a dependency.

## Usage

```bf
using RGBeef;

let red = Color(1, 0, 0, 0); // create a color

if(let green = Color.ParseHex("00FF00")) // parse a hex value

if(let blue = Color.ParseHtmlName("blue")) // parse an html color name
```

## Parsing Color strings

The `Color` class has a handful of parsing methods for common string formats. All parsing methods return a `Result<Color>`.

```bf
if(let color = Color.ParseHex("FF0000"))

// ParseHtmlColor can handle various formats used in web
if(let color = Color.ParseHtmlColor("rgba(255, 255, 255, 255)"))
```

`static Result<Color> ParseHex(StringView string)) // FF0000` 

`static Result<Color> ParseHexAlpha(StringView string)) // FF0000FF` 

`static Result<Color> ParseHexTiny(StringView string)) // F00` 

`static Result<Color> ParseHtmlHex(StringView string)) // #FF0000` 

`static Result<Color> ParseHtmlHexTiny(StringView string)) // #F00` 

`static Result<Color> ParseHtmlRgb(StringView string)) // #rgb(255, 0, 0)` 

`static Result<Color> ParseHtmlRgba(StringView string)) // #rgb(255, 0, 0, 255)` 

`static Result<Color> ParseHtmlName(StringView string)) // red` 

`static Result<Color> ParseHtmlColor(StringView string)) // Any of the above html parsers` 

## Color Manipulations

```bf
let lightRed = Color(1, 0, 0)..Lighten(0.5);
```

You can manipulate `Color` values with the following methods:

`void Lighten(float amount) // Lightens the color by amount 0-1`

`void Darken(float amount) // Darkens the color by amount 0-1`

`void Saturate(float amount) Saturates (makes brighter) the color by amount 0-1`

`void Desaturate(float amount) // Desaturate (makes grayer) the color by amount 0-1`

`void Spin(float degrees) // Rotates the hue of the color by degrees (0-360)`

`void Mix(Color color) // Mixes two colors together`


## Color Distance

```bf
let d = Color(1, 0, 0).Distance(Color(.99999, 0, 0));
```

`Color` also implements a `Distance` method using [`CIEDE2000`](https://en.wikipedia.org/wiki/Color_difference#CIEDE2000)

`float Distance(Color color) // Calculate the distance between two colors`

## Color Spaces

RGBeef supports conversions from and to these colors spaces:

- 8-bit RGB
- 8-bit RGBA
- CMY - Reverse of RGB
- CMYK - Used in printing
- HSL - Attempts to resemble more perceptual color models
- HSV - Models the way paints of different colors mix together
- YUV - Originally a television color format, still used in digital movies
- XYZ (CIE XYZ; CIE 1931 color space)
- LAB (CIE L*a*b*, CIELAB) - Derived from XYZ (Note: a fixed white point is assumed)
- CIELCh, LAB in polar coordinates
- LUV (CIE L*u*v*, CIELUV) - Derived from XYZ (Note: a fixed white point is assumed)
- CIELCH, LUV in polar coordinates, often called HCL
- Oklab (https://bottosson.github.io/posts/oklab/)

The default type is an RGB based type using `float` as its base type (with values ranging from 0 to 1) and is called `Color`.

All color spaces can be created directly by defining their component values:

```bf
let rgb = RGB(255, 0, 0);
let rgba = RGBA(255, 0, 0);
```

Or created from a `Color`:

```bf
let rgb = RGB(Color(1, 0, 0));
let rgba = RGBA(Color(1, 0, 0));
```

For added ergonomics, `Color` has helper properties for easily converting to any color space:

```bf
RGB rgb = Color(1, 0, 0).rgb;
RGBA rgba = Color(1, 0, 0, 0.5f).rgba;
```

And of course, the ability to convert back into a `Color`:

```bf
Color c1 = RGB(1, 0, 0).color;
Color c2 = RGBA(1, 0, 0).color;
```

Color Spaces also come with support for the conversion properties that exist on `Color`:

```bf
// These are equivalent
CMYK cmyk = RGBA(1, 0, 0, 0).color.cymk; 
CMYK cmyk = RGBA(1, 0, 0, 0).cymk; 
```

And shorthand methods for parsing and manipulation:

```bf
RGB lightred = RGB(255, 0, 0)..Lighten(0.5); 

if(let cmyk = CMYK.ParseHtmlName("red"))
    cmyk.Darken(0.5); 
```

[Check the tests for more](https://github.com/farism/RGBeef/src/Tests.bf)

MIT License