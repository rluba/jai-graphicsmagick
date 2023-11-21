AT_COMPILE_TIME :: true;

COMPILE       :: true; // Enable to compile the GraphicsMagick library from source before generating bindings. You probably want libpng, libjpeg, libheif installed before compiling.

GM_PATH :: "GraphicsMagick-1.3.42";
MACOS_X64_HOMEBREW_PATH :: "/usr/local/homebrew"; // This is where my x64 libraries live. Adjust to fit your needs.

DECLARATIONS_TO_OMIT :: string.[
];

#if AT_COMPILE_TIME {
    #run {
        set_build_options_dc(.{do_output=false});
        if !generate_bindings() {
            compiler_set_workspace_status(.FAILED);
        }
    }
} else {
    #import "System";

    main :: () {
        set_working_directory(path_strip_filename(get_path_of_running_executable()));
        if !generate_bindings() {
            exit(1);
        }
    }
}

generate_bindings :: () -> bool {
    #if COMPILE {
		success := build_gm();
		if !success return false;
	}

    output_filename: string;
    opts: Generate_Bindings_Options;
    {
        using opts;

		#if OS == .LINUX {
			array_add(*libpaths, "linux");
		} else #if OS == .MACOS {
			array_add(*libpaths, "macos");
		} else {
			assert(false);
		}
		output_filename = "unix.jai";
		generate_library_declarations = false;
		footer = FOOTER_UNIX;

		gm_include_path := tprint("%/include/GraphicsMagick", PLATFORM_NAME);
        array_add(*libpaths,      tprint("%/lib", PLATFORM_NAME));
        array_add(*libnames,      "libGraphicsMagick");
        array_add(*libnames,      "libGraphicsMagickWand");
        array_add(*include_paths, gm_include_path);
        array_add(*source_files,  tprint("%/wand/magick_wand.h", gm_include_path));
        // array_add(*strip_prefixes, "Magick");

        log_stripped_declarations           = false;
        generate_compile_time_struct_checks = false;
        alias_original_enum_names           = false;
        // array_add(*generate_enums_from_macros_with_prefixes,
        //     "HPDF_ENABLE",
        //     "HPDF_COMP",
        //     "HPDF_GMODE",
        //     "HPDF_STREAM_FILTER",
        //     "HPDF_OTYPE",
        //     "HPDF_OCLASS",
        //     "HPDF_OSUBCLASS",
        //     // "HPDF_FONT", // Unfortunately pulls in some error codes
        // );


        visitor   = gm_visitor;
    }

    return generate_bindings(opts, output_filename);
}

#if OS == .LINUX {
    PLATFORM_NAME :: "linux";
} else #if OS == .MACOS {
    PLATFORM_NAME :: "macos";
} else {
    compiler_report(tprint("Unsupported platform: %", OS));
}

build_gm :: () -> bool {
	install_dir := PLATFORM_NAME;
    success := make_directory_if_it_does_not_exist(install_dir);
    if !success {
        log_error("Could not create directory \"%\"\n", install_dir);
		return false;
    }

	absolute_install_dir := get_absolute_path(install_dir);
	assert(absolute_install_dir != "");

    config_command: [..] string;
    array_add(*config_command,
		"./configure",
        tprint("--prefix=%", absolute_install_dir),
        // Let’s disable a bunch of crap we don’t need:
        "--with-gs=no",
        "--with-jxl=no",
        "--with-magick-plus-plus=no",
        "--with-png=yes",
        "--with-ttf=yes", // For SVG… sigh…
        "--with-x=no",
        "--with-xml=yes", // For SVG… sigh…
	);

    #if OS == .MACOS {
        using options := get_build_options();
        array_add(*config_command,
            tprint("LDFLAGS=-L%/lib", MACOS_X64_HOMEBREW_PATH),
            tprint("CPPFLAGS=-I%/include", MACOS_X64_HOMEBREW_PATH),
            tprint("CFLAGS=-I%/include -mmacosx-version-min=%.%", MACOS_X64_HOMEBREW_PATH, minimum_macos_version.major, minimum_macos_version.minor),
            tprint("CXXFLAGS=-I%/include -mmacosx-version-min=%.%", MACOS_X64_HOMEBREW_PATH, minimum_macos_version.major, minimum_macos_version.minor),
        );
    }

    log("Configuring GraphicsMagick... \"%\"", absolute_install_dir);
    run_or_exit(..config_command,  working_directory = GM_PATH);
    log("Done configuring GraphicsMagick");

    log("Building GraphicsMagick…");
    run_or_exit("make",            working_directory = GM_PATH);
    run_or_exit("make", "check",   working_directory = GM_PATH);
    run_or_exit("make", "install", working_directory = GM_PATH);
	log("Done building GraphicsMagick");

	return true;
}

run_or_exit :: (command: .. string, working_directory := "") -> string {
    // Enable this to see the commands being executed.
    // Might be useful if, for example, you need to compile LLVM on a platform where we don’t have a Jai compiler yet and want to do it manually.
    // log("Executing command \"%\" in directory \"%\"\n", join(..command, separator = " "), working_directory);

    result, output_string, error_string := run_command(..command, working_directory = working_directory, capture_and_return_output = true, print_captured_output = true);
    defer {
        free(error_string);
    }
    if result.exit_code != 0 {
        log_error("Could not run command \"%\" in directory \"%\". Exit code: %\nError:\n%", get_quoted_command_string(command), working_directory, result.exit_code, error_string);
        // if !LIVE_OUTPUT {
        //     log_error("Output:\n%", output_string);
        // }
        exit(1);
    }
    return output_string;
}


gm_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    if !parent_decl {
        if array_find(DECLARATIONS_TO_OMIT, decl.name) {
            decl.decl_flags |= .OMIT_FROM_OUTPUT;
            return .STOP;
        }

		// if (begins_with(decl.name, "HPDF_COUNTRY_") || begins_with(decl.name, "HPDF_LANG_")) {
		// 	decl.decl_flags |= .OMIT_FROM_OUTPUT;
		// 	return .STOP;
		// }

        // if decl.kind == .TYPEDEF {
		// 	inner_name := tprint("_%", decl.name);
		// 	for context.generator.global_scope.members {
		// 		if it.name != inner_name     continue;

		// 		// Don't output the typedef
		// 		decl.decl_flags |= .OMIT_FROM_OUTPUT;

		// 		// Keep the comment, if there is one:
		// 		if decl.comment.text && !it.comment.text {
		// 			it.comment = decl.comment;
		// 		}

		// 		it.output_name = decl.output_name;
		// 		break;
		// 	}
        // }

        // if decl.kind == .ENUM {
            // _enum := cast(*Enum) decl;
            // if decl.output_name == {
                // case "COMP"; #through;
                // case "ENABLE"; #through;
                // case "GMODE"; #through;
                // case "STREAM_FILTER"; #through;
                // case "OTYPE";
                    // _enum.flags |= .IS_ENUM_FLAGS;
                    // _enum.flags |= .VALUES_IN_HEX;
            // }
        // }
    }

    return .RECURSE;
}

#import "Basic";
#import "Bindings_Generator";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "String";
#import "Process";

FOOTER_UNIX :: #string END

#if OS == .MACOS {
    libgraphicsmagick     :: #library,no_dll "macos/lib/libGraphicsMagick";
    libgraphicsmagickwand :: #library,no_dll "macos/lib/libGraphicsMagickWand";
}
#if OS == .LINUX {
    libgraphicsmagick     :: #library,no_dll "linux/lib/libGraphicsMagick";
    libgraphicsmagickwand :: #library,no_dll "linux/lib/libGraphicsMagickWand";
}

END

