# <img src="https://github.com/KoBeWi/Godot-Spritesheet-Generator/blob/master/Media/Icon.png" width="64" height="64"> Godot Spritesheet Generator

A spritesheet generator that takes a list of images and joins them into a single sheet. It also allows to configure number of columns, margin between frames and has a cropping capability which keeps relative offset between frames.

This is not a stand-alone app, it's a single-scene plugin that you can add to your Godot project.

## Example usage

Let's say you have a couple of images like these:

![](https://github.com/KoBeWi/Godot-Spritesheet-Generator/blob/master/Media/ReadmeExampleFiles.png)
[(credit)](https://opengameart.org/content/high-res-fire-ball)

They also have a transparent border that can be cropped.

When you import it into the generator, you will see them layered in a grid, automatically adjusted to optimal number of columns:

![](https://github.com/KoBeWi/Godot-Spritesheet-Generator/blob/master/Media/Screenshot1.png)

They are automatically trimmed from the excessive border. You can change the spacing and number of columns and also rearrage them via drag and drop. When you use Save PNG, it will create a spritesheet, the same as in the view:

![](https://github.com/KoBeWi/Godot-Spritesheet-Generator/blob/master/Media/ReadmeFinalSpritesheet.png)

## Instructions

As mentioned, the generator is just a Godot scene. When you install the plugin, you can use _Project -> Tools -> Open Spritesheet Generator_ option to run the scene. You can also find it in the command palette. Note that it will use your project's default theme and resolution, but it shouldn't be a problem in most cases.

To start, you need to drag and drop a couple of images or a single directory onto the generator's window. Your images will be then processed and you will see a preview of your spritesheet. The images need to be of equal size. Thanks to this requirement, they can be perfectly trimmed while keeping the relative offset of each image intact (normally when you trim images to minimal size, they don't have a common center point anymore).

You can use the Alpha Threshold option to control how much the image is cropped. Any pixel that has alpha value lower than threshold will be subject to being trimmed out. If the value is 0, the frames will be packed with their original size.

From there you have options to change the margins or number of columns. By default, the column count is auto-calculated. The algorithm makes sure that there's a least number of holes and the image layout is as close to square as possible, favoring vertical size over horizontal.

By default, images are arranged alphabetically as in the directory/list you dropped, but you can use drag and drop to re-arrange them. You can also delete images by right-clicking them. A deleted image goes into a dedicated stash (Image Stash button), from where you can re-add it if you change your mind.

When you are ready, you can save the spritesheet to PNG. The spritesheet will be created inside the original frames' directory, using the name of the directory. You can provide a custom name for the spritesheet.

## Spritesheet Editing

The generator can alternatively edit existing spritesheets. If you drop only a single image, a dialog will be opened where you can specify number of rows and columns to cut.

![](https://github.com/KoBeWi/Godot-Spritesheet-Generator/blob/master/Media/ReadmeEditSpritesheet.png)

If you accept, the split images will be added and you will be able to edit the spritesheet as desribed in the instructions above.

## Origin

The reason why this tool was created is that there isn't really any good spritesheet generator that can trim your frames. I had a big list of images that needed to be made into a spritesheet, but their problem was a huge transparent border around each frame. E.g. check this one (I added the outline to better denote the real size:

![](https://github.com/KoBeWi/Godot-Spritesheet-Generator/blob/master/Media/ReadmeBug.png)

It's easy to crop an image, but each frame has a different size and after you crop them all, your spritesheet will be a mess. My generator finds a "globally minimal size", so that frames are cropped, but don't "jump" when put into a spritesheet.

This tool was created for a Godot project, but eventually I realized this is actually useful, so I made it into a plugin. End of story, hope someone finds it useful and worth the effort of making this asset xd

___
You can find all my addons on my [profile page](https://github.com/KoBeWi).

<a href='https://ko-fi.com/W7W7AD4W4' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
