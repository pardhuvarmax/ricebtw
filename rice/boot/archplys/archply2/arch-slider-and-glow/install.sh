#!/bin/bash

THEME_DIR="/usr/share/plymouth/themes/arch-slider-and-glow"

if [[ $1 == "install" ]]; then
        if [[ -e $THEME_DIR ]];then
                echo "Already installed: $THEME_DIR"
                exit 0
        fi

        if [[ ! -e "./arch-slider-and-glow.plymouth" ]]; then
                echo "Please run inside repo directory"
                exit 1
        fi

        if [[ $EUID -ne 0 ]]; then
                echo "Please run with sudo or doas"
                exit 1
        fi

        ARROW="\033[32m==>\033[0m"

        echo -e "$ARROW Copying files to $THEME_DIR ..."
        mkdir -p $THEME_DIR
        cp -r *.plymouth resources $THEME_DIR/

        echo -e "$ARROW Applying permissions ..."
        find $THEME_DIR -type d -exec chmod 755 {} +
        find $THEME_DIR -type f -exec chmod 644 {} +
        chown -R root:root $THEME_DIR
 
        echo -e "$ARROW Applying theme ..."
        plymouth-set-default-theme -R arch-slider-and-glow

        echo -e "$ARROW \033[32mFinished Install\033[0m"

elif [[ $1 == "remove" ]]; then
        read -p "Are you sure to remove theme? [Y/n]: " confirm
        if [[ $confirm != [yY] ]];then
                echo "Canceled"
                exit
        fi

        if [[ $EUID -ne 0 ]]; then
                echo "Please run with sudo or doas"
                exit 1
        fi


        # Pick a fallback theme for removing
        FALLBACK_THEME=$(plymouth-set-default-theme --list | grep -v "arch-slider-and-glow" | head -n 1)
 
        ARROW="\033[32m==>\033[0m"

        echo -e "$ARROW Changing theme to: $FALLBACK_THEME"
        plymouth-set-default-theme -R $FALLBACK_THEME
        echo -e "$ARROW Removing files ..."
        rm -rf $THEME_DIR

        echo -e "$ARROW \033[32mFinished Remove\033[0m"

else
        echo "Usage: install.sh [ install | remove ]"
        exit 1
fi
