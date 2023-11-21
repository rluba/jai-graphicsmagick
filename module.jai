#load "unix.jai";

#import "POSIX";

// Additional libraries needed by GM (depending on what you had installed when you built GM)
libbz2      :: #system_library "libbz2";
libheif     :: #system_library "libheif";
libjpeg     :: #system_library "libjpeg";
liblcms2    :: #system_library "liblcms2";
libpng      :: #system_library "libpng";
libtiff     :: #system_library "libtiff";
libwebp     :: #system_library "libwebp";
libwebpmux  :: #system_library "libwebpmux";
libxml2     :: #system_library "libxml2";
libfreetype :: #system_library "libfreetype";
zlib        :: #system_library "libz";
zstd        :: #system_library "libzstd";
#if OS == .LINUX {
    libomp      :: #system_library "libomp";
}

