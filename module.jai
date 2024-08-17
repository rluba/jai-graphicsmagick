#load "unix.jai";

#import "POSIX";

// Additional libraries needed by GM (depending on what you had installed when you built GM)
libbz2      :: #library,system,link_always "libbz2";
libheif     :: #library,system,link_always "libheif";
libjpeg     :: #library,system,link_always "libjpeg";
liblcms2    :: #library,system,link_always "liblcms2";
libpng      :: #library,system,link_always "libpng";
libtiff     :: #library,system,link_always "libtiff";
libwebp     :: #library,system,link_always "libwebp";
libwebpmux  :: #library,system,link_always "libwebpmux";
libxml2     :: #library,system,link_always "libxml2";
libfreetype :: #library,system,link_always "libfreetype";
zlib        :: #library,system,link_always "libz";
zstd        :: #library,system,link_always "libzstd";
#if OS == .LINUX {
    libomp  :: #library,system,link_always "libomp5";
    libm    :: #library,system,link_always "libm";
}

