```
func colorTemperatureToRGB(_ kelvin: Double) -> Color {
    let temp = kelvin / 100.0
    var red, green, blue: Double

    // Rot
    if temp <= 66 {
        red = 255
    } else {
        red = 329.698727446 * pow(temp - 60, -0.1332047592)
        red = max(0, min(255, red))
    }

    // Grün
    if temp <= 66 {
        green = 99.4708025861 * log(temp) - 161.1195681661
    } else {
        green = 288.1221695283 * pow(temp - 60, -0.0755148492)
    }
    green = max(0, min(255, green))

    // Blau
    if temp >= 66 {
        blue = 255
    } else if temp <= 19 {
        blue = 0
    } else {
        blue = 138.5177312231 * log(temp - 10) - 305.0447927307
        blue = max(0, min(255, blue))
    }

    return Color(
        red: red / 255.0,
        green: green / 255.0,
        blue: blue / 255.0
    )
}
```

```
let temperatures = stride(from: 2000, through: 6500, by: 500)
let gradientColors = temperatures.map { colorTemperatureToRGB(Double($0)) }

let gradient = LinearGradient(
    gradient: Gradient(colors: gradientColors),
    startPoint: .leading,
    endPoint: .trailing
)

```

```
if (currentTheme == AppTheme.Dark)
    temp += "?forceDark=true";
else
    temp += "?forceDark=false";
```
