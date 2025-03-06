## Installation

Just unzip `FitHack.zip` wherever you want and create a desktop shortcut to `FitHack.exe`.

## Connecting Sensors

You can pair with sensors from the devices tab in FitHack's launcher. Don't close the launcher while you're playing.

This tool has currently only been tested with cadence sensors and a chest strap heart rate monitor, both Wahoo brand.
It *should* work with other BLE cadence and heart sensors.
However, some brands of heart sensor do appear to be locked down to their own apps.

Please let me know how it goes with other brands of sensors. I can add sensors to this list and try to add support for brands that don't work.

## Loading into a Game

Launch your game and then select it from FitHack's games tab. If you don't see your game, try checking `show all processes`.

If it works, you should see FitHack's overlay in the game. You may need to adjust the game's overlay settings. See the overlay troubleshooting section for more info.

## The Overlay

The overlay displays info about your activity level and various gameplay effects. From the overlay, you can also run mods and change settings.

You can toggle the overlay by pressing `F1`.

## Installing Mods

Place your mods under run/mods. 

Be very careful when installing mods from the internet. 
Mods run with the same permissions as the game they're loaded into. 
Only use mods from trusted sources.

## Running Mods

Select a mod from the mods tab in the overlay.

You can pause the mod by pressing `F2`.

## Troubleshooting

### Overlay Not Showing

FitHack uses an external overlay window by default. This may not work in older fullscreen games. FitHack has options to hook into various graphics libraries to display directly in the game window. You can get to the game's settings from the launcher's games tab.

| Setting    | Description                                                                 |
|------------|-----------------------------------------------------------------------------|
| directx9   | Hook DirectX9                                                               |
| directx10  | Hook DirectX10                                                              |
| directx11  | Hook DirectX11                                                              |
| directx12  | Hook DirectX12                                                              |
| opengl     | Hook OpenGL                                                                 |
| vulkan     | Hook Vulkan                                                                 |
| auto       | Tries to guess which library to hook. (Not recommended)                     |
| external   | Uses an external overlay window. May not work with older fullscreen games.  |
