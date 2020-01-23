#!/bin/bash -                                                                                                                                                                                                  
                                                                                                                                                                                                               
# This shell script would create a chrooted jail for a given user                                                                                                                                              
# The file can only be executed by root                                                                                                                                                                        
                                                                                                                                                                                                               
# Set up some env variables                                                                                                                                                                                    
foldername="chroot"                                                                                                                                                                                            
JAIL="/home/chroot/"                                                                                                                                                                                           
                                                                                                                                                                                                               
if [ -d $JAIL ]; 
then
    # Skip to Step 6
    echo "$JAIL already exists!"
else
    # Step 1: Start by creating the chrooted jail                                                                                                                                                                                                                         
    mkdir -p "${JAIL}"                                                                                                               
    # Step 2: Create the /dev files by using the `mknod` command                                                                                                                                                                                                          
    mkdir -p "${JAIL}dev/"                                                                                                           
    cd "${JAIL}dev/"                                                                                                                 
    mknod -m 666 null c 1 3                                                                                                                                                                                                                                               
    mknod -m 666 tty c 5 0                                                                                                                                                                                                                                                
    mknod -m 666 zero c 1 5                                                                                                                                                                                                                                               
    mknod -m 666 random c 1 8                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                          
    # Step 3: Set the appropriate permission on the chrooted jail. Note that the chrooted jail and its sub directories                                                                                                                                                    
    #          and subfiles must be owned by root user, and not writable by any normal user or group:                                                                                                                                                                     
    chown root:root "${JAIL}"                                                                                                        
    chmod 0755 "${JAIL}"                                                                                                             
                                                                                                                                                                                                                                                                          
    # Step 4: Set up interactive SSH chrooted jail                                                                                                                                                                                                                        
    # Step 5: Link the required bin/ and lib/                     
    # Reference: https://unix.stackexchange.com/questions/4897/providing-bin-and-lib-inside-a-chroot-jail                                                                                                                                                                 
                                                                  
    copy_file_and_dependencies() {                                
        PROGRAM="$1"                                              
        DEPENDENCIES="$(ldd "$PROGRAM" | awk '{ print $3 }' | grep -v '(' | grep -v 'not a dynamic executable')"                                                                                                                                                          
                                                                  
        mkdir -p "${JAIL}$(dirname $PROGRAM)"                     
        cp -Lv "$PROGRAM" "${JAIL}${PROGRAM}"                     
                                                                  
        for f in $DEPENDENCIES;                                   
        do                                                        
            mkdir -p "${JAIL}$(dirname $f)"                       
            cp -Lv "$f" "${JAIL}${f}"                             
        done                                                      
                                                                  
    }                                                             
    export copy_file_and_dependencies      
    
    copy_file_and_dependencies /etc/ld.so.cache
    copy_file_and_dependencies /bin/sh
    copy_file_and_dependencies /bin/bash
    # Copy the lib64 file
    mkdir "${JAIL}lib64"
    cp -v /lib64/* "${JAIL}lib64/"
    # Add Linux commands
    linux_commands=("ls" "mkdir" "touch" "cat" "man" "vim" "date" "tree" "less" "more" "rm" "dir" "tar" "which" "sed" "grep")
    for command in ${linux_commands[*]}
    do
        copy_file_and_dependencies /bin/"$command"
    done

    # Create home dir in chroot/
    mkdir "${JAIL}home/"
fi

exit 0

