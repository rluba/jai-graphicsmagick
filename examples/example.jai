main :: () {
    InitializeMagick(null);
    wand := NewMagickWand();

    status := MagickReadImage(wand, "logo.png");
    check_for_error(wand, status);

    width := MagickGetImageWidth(wand);
    height := MagickGetImageHeight(wand);
    log("Old dimensions: %x%", width, height);

    status = MagickResizeImage(wand, width / 2, height / 2, .LanczosFilter, 1.0);
    check_for_error(wand, status);

    width = MagickGetImageWidth(wand);
    height = MagickGetImageHeight(wand);
    log("New dimensions: %x%", width, height);

    status = MagickWriteImage(wand, "logo_result.png");
    check_for_error(wand, status);

    log("ALL OK");
}

check_for_error :: (wand: *MagickWand, status: u32) {
    if status != MagickPass {
        severity: ExceptionType;
        description := MagickGetException(wand, *severity);
        log_error("GraphicsMagick error: % %", severity, to_string(description));
        exit(1);
    }
}

#import,file "../module.jai";

#import "Basic";
