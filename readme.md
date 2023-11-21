# Jai bindings for the GraphicsMagick library

Basic Jai bindings for the ["Wand" C API](http://www.graphicsmagick.org/wand/wand.html) of [GraphicsMagick](http://www.graphicsmagick.org).

## Dependencie

GraphicsMagick needs a **ton** of dependencies installed to do its work. My list for Debian Bullseye currently looks like this for compiling GraphicsMagick:

```
libbz2-dev 
libfreetype6-dev 
libheif-dev 
libjpeg-dev 
liblcms2-dev 
libpng-dev 
libtiff-dev 
libwebp-dev 
libxml2-dev 
libzstd-dev 
pkg-config # Needed for GraphicsMagick’s configure script to detect libfreetype. 🤦
zlib1g-dev 
```

And to link against GraphicsMagick on Debian Bullseye, you need at least:

```
libbz2-1.0
libfreetype6 
libheif1 
libjpeg62-turbo 
liblcms2-2 
libomp5 
libpng16-16 
libtiff5 
libwebp6 
libwebpmux3
libxml2 
libzstd1 
```

