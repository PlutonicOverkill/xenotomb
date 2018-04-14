#!/bin/bash

echo
echo Clearing intermediary compilation files...
echo

# clear out the build folder
if ! [ -d bin ]; then
    mkdir bin
fi

if [ -d bin/ir ]; then
    rm -r -- bin/ir
fi

if [ -d bin/build ]; then
    rm -r -- bin/build
fi

# create directories for the binaries
mkdir bin/ir # binaries built with gdcc go here
mkdir bin/build # this is what goes into the final .pk3

# delete all acs binaries except libc.
# this is because it takes a long time to compile, so
# it's not something you want to be doing every time
if [ -d bin/build/acs ]; then
    /usr/bin/find bin/build/acs -type f ! -name 'libc.lib' -delete
fi

echo
echo Compiling libraries...
echo

# loop through each library directory
for lib_dir in src/src/lib/*; do
    if ! [ -d $lib_dir ]; then
        continue
    fi

    echo

    # remove trailing slash
    lib_dir=${lib_dir%/}

    acs_script_exist=false
    c_script_exist=false
    script_exist=false

    # check for scripts
    set -- ${lib_dir}/*.acs
    if [ -f "$1" ]; then
        acs_script_exist=true
        script_exist=true
    fi
    set -- ${lib_dir}/*.c
    if [ -f "$1" ]; then
        c_script_exist=true
        script_exist=true
    fi

    if [ "$script_exist" = true ]; then
        echo Scripts found in $lib_dir

        # get immediate map directory
        lib_directory=${lib_dir#src/src/}
        lib_name=${lib_dir#src/src/lib/}

        mkdir -p bin/ir/$lib_directory
        mkdir -p bin/build/acs

        # check AUTOLOAD.txt for libraries to load
        link_options=''
        if [ -f $lib_dir/AUTOLOAD.txt ]; then
            while read lib_autoload; do
                echo Autoloading library $lib_autoload
                link_options+="-l${lib_autoload}"
            done < $lib_dir/AUTOLOAD.txt
        fi

        # recompile all ACS scripts
        if [ "$acs_script_exist" = true ]; then
            echo Compiling ACS scripts...

            ./tools/gdcc/gdcc-acc --warn-all --bc-target=ZDoom $link_options -c $lib_dir/*.acs bin/ir/$lib_directory/acs.obj
        fi

        link_libc_options=''

        # recompile all C scripts
        if [ "$c_script_exist" = true ]; then
            if test -n "$(/usr/bin/find bin/build/acs/ -name 'libc.lib' -print -quit)"; then
                echo libc already exists.
            else
                echo Compiling libc...
                tools/gdcc/gdcc-makelib --bc-target=ZDoom --bc-zdacs-init-delay --alloc-min Sta "" 1000000000 libGDCC libc -o bin/build/acs/libc.lib
            fi

            echo Compiling C scripts...
            link_libc_options='-llibc'

            ./tools/gdcc/gdcc-cc --warn-all --bc-target=ZDoom $link_libc_options $link_options -c $lib_dir/*.c bin/ir/$lib_directory/c.obj
        fi

        # link scripts into BEHAVIOR file

        echo Linking scripts...
        ./tools/gdcc/gdcc-ld --warn-all --bc-target=ZDoom --bc-zdacs-init-delay $link_libc_options $link_options bin/ir/$lib_directory/*.obj bin/build/acs/$lib_name.lib

        if [ -f $lib_dir/.LOADACS ]; then
            echo $lib_name | dd of=bin/build/LOADACS.txt
        fi

        echo Library \'$lib_name\' compiled.
    else
        echo No scripts found in $lib_dir
    fi
    
done

echo
echo Compiling maps...
echo

# loop through each map directory
for map_dir in src/src/maps/*; do
    if ! [ -d $map_dir ]; then
        continue
    fi

    echo

    # remove trailing slash
    map_dir=${map_dir%/}

    # search for .wad files
    # get newest map in folder
    # in case of multiple .wads
    newest_map=$(/usr/bin/find ${map_dir} -name '*.wad' -print -quit)
    if test -n $newest_map; then
        mkdir -p bin/build/maps

        # get immediate map directory
        map_path=$newest_map
        map_directory=${map_dir#src/src/}
        newest_map=$(basename "$newest_map")

        echo Map files found in $map_dir
        echo Using map file $newest_map

        acs_script_exist=false
        c_script_exist=false
        script_exist=false

        # check for scripts
        set -- ${map_dir}/*.acs
        if [ -f "$1" ]; then
            acs_script_exist=true
            script_exist=true
        fi
        set -- ${map_dir}/*.c
        if [ -f "$1" ]; then
            c_script_exist=true
            script_exist=true
        fi

        if [ "$script_exist" = true ]; then
            echo Found scripts in $map_dir

            # extract map .wad into ir directory
            echo Extracting map to bin/ir/$map_directory...
            mkdir -p bin/ir/$map_directory
            ./tools/gdcc/gdcc-ar-wad wad:"${map_path}" --output "bin/ir/${map_directory}" --extract

            # check AUTOLOAD.txt for libraries to load
            link_options=''
            if [ -f $lib_dir/AUTOLOAD.txt ]; then
                while read map_autoload; do
                    echo Autoloading library $map_autoload
                    link_options+="-l${map_autoload}"
                done < $map_dir/AUTOLOAD.txt
            fi

            # recompile all ACS scripts
            if [ "$acs_script_exist" = true ]; then
                echo Compiling ACS scripts...

                ./tools/gdcc/gdcc-acc --warn-all --bc-target=ZDoom $link_options -c $map_dir/*.acs bin/ir/$map_directory/acs.obj
            fi

            link_libc_options=''

            # recompile all C scripts
            if [ "$c_script_exist" = true ]; then
                if test -n "$(/usr/bin/find bin/build/acs/ -name 'libc.lib' -print -quit)"; then
                    echo libc already exists.
                else
                    echo Compiling libc...
                    tools/gdcc/gdcc-makelib --bc-target=ZDoom --bc-zdacs-init-delay --alloc-min Sta "" 1000000000 libGDCC libc -o bin/build/acs/libc.lib
                fi

                echo Compiling C scripts...
                link_libc_options='-llibc'

                ./tools/gdcc/gdcc-cc --warn-all --bc-target=ZDoom $link_libc_options $link_options -c $map_dir/*.c bin/ir/$map_directory/c.obj
            fi

            # link scripts into BEHAVIOR file

            echo Linking scripts...
            ./tools/gdcc/gdcc-ld --warn-all --bc-target=ZDoom --bc-zdacs-init-delay $link_libc_options $link_options bin/ir/$map_directory/*.obj bin/ir/$map_directory/behavior.lib

            # pack everything into wad file in \maps

            #   MAP01       empty
            #   TEXTMAP     extracted TEXTMAP from map .wad
            #   SCRIPTS     map script source (not 100% necessary)
            #   BEHAVIOR    compiled map script
            #   ZNODES      extracted ZNODES from map .wad
            #   ENDMAP      empty

            echo Packing files into maps/$newest_map...
            tools/gdcc/gdcc-ar-wad file:MAP01="bin/ir/${map_directory}/MAP01/MAP01" file:TEXTMAP="bin/ir/${map_directory}/MAP01/TEXTMAP" file:BEHAVIOR="bin/ir/${map_directory}/behavior.lib" file:ZNODES="bin/ir/${map_directory}/MAP01/ZNODES" file:ENDMAP="bin/ir/$map_directory/MAP01/ENDMAP" --output "bin/build/maps/${newest_map}"
        else
            # no scripts
            echo No scripts found in %%G.

            echo Copying map file...

            cp $map_path bin/build/maps/$newest_map
        fi

        echo Map \'$newest_map\' compiled.
    else
        echo No maps found in $map_dir
    fi
done

echo

# now we need to copy all the files
# and directories that we haven't already
for src_file in src/*; do
    if ! [[ $src_file = src/src ]]; then
        echo Copying $src_file

        destination=bin/build/${src_file#src/}
        mkdir -p $(dirname "${destination}") && cp -r $src_file $destination

    fi
done

echo Compilation complete.
