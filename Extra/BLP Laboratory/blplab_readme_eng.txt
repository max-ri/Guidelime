// >--------------------------------------------------------------------------------------------<
// >> BLP Lab v0.5.0 readme file (English version)
// >--------------------------------------------------------------------------------------------<

[ WARNING ]
THIS PROGRAM IS DISTRIBUTED "AS IS". NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED. YOU USE IT AT YOUR OWN RISK. THE AUTHOR WILL NOT BE LIABLE FOR DATA LOSS, DAMAGES, LOSS OF PROFITS OR ANY OTHER KIND OF LOSS WHILE USING OR MISUSING THIS SOFTWARE.



[ CONTENTS ]
- Description
- Batch converter window
- Batch BLP optimizer window
- File format options window
- BLP comments window
- Alpha channel window
- About & credits
- Version history



[ DESCRIPTION ]
BLP Laboratory (BLP Lab) is a tool for working with BLP textures. "Working" includes viewing, converting and some other stuff. Features:
- Supports following file formats: BMP, JPG, TGA, PNG, BLP (supports BLP2 textures), DDS (supports non-complex textures);
- May convert multiple files at once;
- Can add/remove alpha channel when saving;
- Gives detailed information about opened image file;
- Provides additional file format options when saving;
- Can optimize BLP files to decrease their size (doesn't affect quality);
- May display alpha channel and transparency on image.



[ BATCH CONVERTER ]
This window allows you to convert multiple files to specified format.

- Source formats -
Here you can choose, files of which extensions to process. All options checked by default.

- Destination format -
Selecting output format for processed files.

- Source folder -
Where to pick files to process.

- Process files in subfolders -
Allows to process all files (not only in the root of folder) in specified source folder.

- Destination folder -
Where processed files will be placed.

- Keep folder structure -
How this option works is shown in example:
Source folder		C:\input\
One of source files		C:\input\Textures\tex.tga
Converted file (option disabled)	C:\output\tex.blp
Converted file (option enabled)	C:\output\Textures\tex.blp



[ BATCH BLP OPTIMIZER ]
There you can optimize BLPs to decrease file size. I should note, that optimizing doesn't reduce quality of images. It just removes unnecessary information from the file.

- Source folder -
Program will pick files to process in this folder.

- Process files in subfolders -
Allows to process all files (not only in the root of folder) in specified source folder.

This window also has a log below the progress bar. It shows file names, that were optimized and size difference after optimization.



[ FILE FORMAT OPTIONS ]
This window provides advanced file format options.

==== BLP 1 OPTIONS

- Paletted -
Image will be saved in paletted format. Palette is located right after BLP header, and has limited count of entries (256). During image process, if current colour could not be found in palette, it is replaced with most approximate colour from palette.

- Compress palette -
Basically, palette size is fixed and equal to 1024 bytes. This option will reduce palette entries to number of colours in image. Example: you want to convert image with white text and black background. So when this option is checked, palette size wil be just only 8 bytes (2 colors * 4 bytes entry). This option as well as "Merge headers" reduces output file size.

- Error diffusion -
Implies Floyd-Steinberg dithering algoritm (http://en.wikipedia.org/wiki/Floyd-Steinberg_dithering). Usually high-colour image have noticeable artifacts and overall looks ugly after paletting. This option can reduce those artifacts, so image will look better. Image processed with this option have bigger size in archive, than image processed without it.

- Compressed (JPEG) -
Image will be saved in jpeg format (http://en.wikipedia.org/wiki/JPEG). It is most applicable for images with a huge number of unique colours. Such BLP images have minimal size reduction, when packed to MPQ (or any other archive). Therefore this format is called "compressed". Can be saved with 1-100% quality. Spec recommends to use 60-80%, which is both decent quality and size.

- Merge headers -
BLP format allows to have one header for all jpeg images (mipmaps) in file, so file size can be reduced a bit. This option generates such header. Also, it has no effect, when you have "1" in "Mipmap count".

- Progressive encoding -
Output jpeg image will be in progressive format. File size can vary (both bigger or smaller in compare with standard encoding), but it is compressed a lot better in MPQ.

- Mipmap count -
Ñount of generated mipmaps for image (http://en.wikipedia.org/wiki/Mipmap).

==== BLP 2 OPTIONS

- Paletted -
- Compress palette -
- Error diffusion -
See "BLP 1 options".

- Compressed (DXTC) -
Image will be saved in dxtc format (http://en.wikipedia.org/wiki/S3TC). This algorithm works similar to paletting, but processes 4x4 blocks of pixels, therefore quality of image would be better. Also, resulting files are smaller than the same files in paletted format.

- Error diffusion -
- Mipmap count -
See "BLP 1 options".

==== DDS OPTIONS

- True Color -
Image will be saved in true color format (http://en.wikipedia.org/wiki/RGB_color_model#Truecolor). That means "as is" format, no color transformations applied during saving.

- Compressed (DXTC) - 
See "BLP 2 options".

- Error diffusion -
- Mipmap count -
See "BLP 1 options".

==== TGA OPTIONS

- Paletted -
- Compress palette -
- Error diffusion -
See "BLP 1 options".

- True Color -
See "DDS options".

- Top-left orientation -
First line of image for TGA basically starts for bottom-left corner. That's basically read by image viewers as "vertical mirrored" image. This option enables normal line order during saving. Can be useful sometimes (for example, to have better compression ratio of the specified TGA image in archive).

- Run-Length Encoding -
Enables Run-Length Encoding (http://en.wikipedia.org/wiki/Run-length_encoding). It's kind of compression, that TGA format supports. Good for images with big blocks of same pixels. Nevertheless, often it's better to have in archive TGA files NOT encoded with RLE.

- Line override -
Enables only when RLE option is selected. While encoding, it ignores the end of the current line and continues the packet on the next line. This option slighty improves compression, but encoded image cannot be read properly by some image viewers.

==== PNG OPTIONS

- Compression ratio -
I think it's self-explanatory. Value range is 0..9. Bigger number means lesser file size.

- Filters -
Contains options for simple pixels' operations, that can provide better compression of image.

==== JPG OPTIONS

- Quality -
Again, it's self-explanatory. Value range is 1..100. Bigger number means better quality and bigger file size.

- Progressive encoding -
See "BLP 1 options".



[ BLP COMMENTS ]
This window allows you to add some comments to the BLP file. Comments are added to the unused space in the BLP header, therefore you will see no size difference between files. Maximal available comment length depends on width and height of the image.

Currently comments in BLP1 are only supported.



[ ALPHA CHANNEL ]
This window have options for basic alpha channel manipulations.

- Leave with no changes -
Self-explanatory.

- Add opaque alpha channel -
Adds alpha channel filled with white colour. This option overrides existing alpha channel.

- Remove alpha channel -
Fully removes alpha channel from image. Compressed BLP is the exception, because alpha channel cannot be removed there, so it is just filled with white colour.

- Spec decides that for you -
Automatically determines for each file what to do with alpha channel. If the alpha channel is fully transparent or opaque, this option will remove it, as described above (see "Remove alpha channel").

- Transparent 1 pixel border -
Creates transparent border for placing image with CreateImage() function.



[ CREDITS ]
Author: Shadow Daemon (also known as Spec).
- Toadcop - first tester and user, made icons for the program.
- NETRAT - idea stormer and bug finder.
- Dron, vsparker, Wolverine, Rewenger - testing and useful ideas.



[ VERSION HISTORY ]

[ 0.5.0.500 ] // [ 31.10.2010 ]

++ Added BLP2 support for saving in paletted and DXTC format
++ Added DDS support for saving in DXTC format
++ Added TGA support for saving paletted images and with RLE
++ Added options for BLP2 format
++ Added options for DDS format
++ Added options for TGA fromat
++ Added options for PNG format
++ Added options for JPG format
++ Added displaying information for DDS format
++ Added displaying information for TGA format
++ Added displaying information for PNG format
++ Added displaying information for JPG format
++ Added hotkeys for zooming (Ctrl and +/- on numpad) and browsing files (Ctrl+arrows)
== Extended PNG image support with paletted 8-bit format
== Improved JPG image loading speed
## Fixed bug with showing alpha bit depth on paletted BLP2 images
## Fixed bug with Lanczos resizing algorithm
## Fixed bug with moving maximized window

[ 0.4.1.422 ] // [ 17.04.2010 ]
++ Added file browser
++ Added option for keeping folder structure in mass converter
++ Added optimization for paletted BLPs
## Fixed bug happened while optimizing compressed BLPs with fake mipmaps 

[ 0.4.0.404 ] // [ 04.03.2010 ]
++ Added BLP optimization
++ Added BLP comments feature
++ Added 1 pixel border variant to alpha-channel settings
++ Added DDS support (for simple textures in RGB and DXT formats)
== Changed displaying of mipmap info
== Now window resizes when opening image with smaller dimensions
## Fixed bug with BLP quality definition
## Fixed bug with palette count calculation
## Fixed bug with transparency displaying
## Fixed bug with small mipmaps resizing by Lanczos
## Fixed recognition of non-lower case extensions in mass converter
## Fixed recognition of BLP2 without alpha-channel

[ 0.3.2.362 ] // [ 11.11.2009 ]
++ Added BLP quality displaying
++ Added BLP JPEG encoding type displaying
++ Added optional usage of Lanczos resampling
++ Added optional BLP association
## Fixed bug with transparency displaying
## Fixed bug with scrolling bars
## Fixed bug with opening some paletted BLPs

[ 0.3.1.333 ] // [ 02.09.2009 ]
++ Added option to show/hide info about BLP
++ Added Lanczos resampling algorithm to zoom
++ Added centering image feature
== Now zoom changing ratio depends on current zoom
## Fixed bug when saving compressed BLP without merging headers
## Fixed bug with opening bitmaps that were saved in Photoshop
## Fixed some bugs, caused by changing language

[ 0.3.0.307 ] // [ 02.08.2009 ]
++ Added BLP2 support (for opening)
++ Added error diffusion feature (for paletted BLPs)
++ Added progressive encoding feature (for compressed BLPs)
++ Added subfolders processing feature
## Fixed bug with folders in mass converter

[ 0.2.4.285 ] // [ 25.07.2009 ]
++ Added PNG format support
++ Added resizing window by image size feature
++ Added one copy of program at once feature
## Fixed bug with mipmaps when opening BLP file via drag-n-drop
// Removed 512x512 limit when saving to BLP

[ 0.2.3.265 ] // [ 22.07.2009 ]
++ Added language support
++ Added "Use manifest" option
== Changed memory allocation method for opening JPG
## Now current file name is also displayed in program title on taskbar
## Fixed bugs related to incorrect size definiton of BLP
## Fixed bug when opening non 24-bit or 32-bit image
## Fixed bug with loading and saving BLP options

[ 0.2.2.242 ] // [ 19.07.2009 ]
++ Added "Show alpha" and "Show transparency" buttons to the panel
++ Added messages for exceptions that mostly could happen
++ New "Zoom in" and "Zoom out" icons
== Now text in edit boxes can be selected with CTRL+A
== Now when saving to paletted BLP, color count is taken into account
## Fixed bug related with that the source folder does not contain the desired files

[ 0.2.1.220 ] // [ 18.07.2009 ]
## Added configuration loading and saving
## Now when switching between mipmaps, color count is calculated again

[ 0.2.0.213 ] // [ 15.07.2009 ]
## Added alpha channel options
## Now when switching between mipmaps, zoom is applied as well
## Fixed bug with size when opening compressed BLPs

[ 0.1.8.203 ] // [ 11.07.2009 ]
++ Added progress bar to mass converter
## Fixed mipmap size issues

[ 0.1.7.195 ] // [ 09.07.2009 ]
++ Added formats selecting feature to mass converter
## Fixed bug with saving to TGA
## Fixed bug with saving to JPG

[ 0.1.6.184 ] // [ 03.07.2009 ]
++ Added image zoom feature

[ 0.1.5.179 ] // [ 27.06.2009 ]
++ Added scroll bars when loading big images
++ Added basic JPEG support
## Fixed BMP loading bug

[ 0.1.4.166 ] // [ 21.06.2009 ]
++ Added TGA RLE format support (for opening)
++ Added BLP header size display
++ Added unique color count display

[ 0.1.3.151 ] // [ 17.06.2009 ]
++ Added drag-n-drop
++ New icon & about window
== Now current file name is displayed in window title

[ 0.1.2.139 ] // [ 14.06.2009 ]
== Now BLP information is being cleared when opening non-BLP image
## Fixed file extension bug when saving file
## Fixed orientation tag when saving to TGA

[ 0.1.2.131 ] // [ 07.06.2009 ]
## Fixed bug with slash in the folder path
## Fixed bug when saving picture w/o alpha channel to compressed BLP

[ 0.1.2.125 ] // [ 30.05.2009 ]
++ Added alpha channel preview
++ Added transparency preview
++ Added TGA & BMP support

[ 0.1.1.110 ] // [ 24.05.2009 ]
++ Added mipmap preview
== Changed main window interface
## Fixed bug with alpha channel

[ 0.1.0.100 ] // [ 17.04.2009 ]
^^ Initial release

______________________________________________
"/quit Shadow_Daemon" not supported by kernel.