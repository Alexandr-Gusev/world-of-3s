ffmpeg -i ../python/res/%%03d.png -c:v libx264 -r 20 -pix_fmt yuv420p output.mp4
ffmpeg -i output.mp4 -filter_complex "[0:v] palettegen" palette.png
ffmpeg -i output.mp4 -i palette.png -r 20 -s 640x360 -filter_complex "[0:v][1:v] paletteuse" output.gif
