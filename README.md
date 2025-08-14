# <img src="https://github.com/KoBeWi/Godot-Spritesheet-Generator/blob/master/Media/Icon.png" width="64" height="64"> Godot Spritesheet Generator

An app for creating and editing spritesheets. It can join multiple images into a spritesheet and allows cropping and basic editing of frames.

## Functionality Overview

- Making spritesheets from multiple files. They can be added indivitually or you can add the whole directory.
- Frame size is automatically determined from added images, but can be changed.
- Number of sheet's columns is automatically determined from image count to make optimal image size.
- Frames can be reordered, duplicated and deleted.
- Frames can be cropped, with support for "smart crop" that ensures the images' contents stay in the same relative position.
- Frames can have basic effects applied: mirroring, rotating, color modulation and background removal.
- Frames can be added by cutting an existing spritesheet, which allows to edit it.
- The app has built-in preview for spritesheet's animation.

### Smart Crop

The frames can be cropped using either regular Crop or Smart Crop. Let's say you have 4 images of a rotating ball with arrow:

![](Media/Arrows.webp)

You can see the frames have a transparent border that could be removed. Regular Crop will remove all transparent margins in each frame:

![](Media/ArrowsCrop.webp)

While Smart Crop will perform the trimming "globally", i.e. taking frame relative offsets:

![](Media/ArrowsSmart.webp)

### Spritesheet repack

Spritesheet-inator can be used to import old spritesheets and convert them to newer format. See this spritesheet for example:

![](Media/bat_chase.webp)

It's a sprite from Little Fighter 2. It has solid black background, frame separators, and extra margin in the bottom-right. This can be fixed using the Cut tool and Remove Color effect:

![](Media/BatRepack.webp)

The final image is neatly cut and has transparent background:

![](Media/BatFinal.webp)

## Usage

![](Media/MainScreen.webp)

TODO

## Origin

The reason why this tool was created is that there isn't really any good spritesheet generator that can trim your frames. I had a big list of images that needed to be made into a spritesheet, but their problem was a huge transparent border around each frame. E.g. check this one (I added the outline to better denote the real size):

![](https://github.com/KoBeWi/Godot-Spritesheet-Generator/blob/master/Media/ReadmeBug.webp)

It's easy to crop an image, but each frame has a different size and after you crop them all, your spritesheet will be a mess. I made a quick tool that finds a "globally minimal size", so that frames are cropped, but don't "jump" when put into a spritesheet.

Eventually I made it into a fully-fledged editor plugin called Spritesheet Generator, and as I had more ideas, I reworked the UI, added some functionality, and now it's a spritesheet editing app xd

___
You can find all my addons on my [profile page](https://github.com/KoBeWi).

<a href='https://ko-fi.com/W7W7AD4W4' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
