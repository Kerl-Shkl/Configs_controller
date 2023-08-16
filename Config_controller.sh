#!/bin/bash

# Config_collector: script for manage config file. Vim, Alacritty, I3, ZSH

MSG_COLNEW="File in collection is newer than current config. Update? (y/n)> "
MSG_CONNEW="Current config is newer than file in collection. Update? (y/n)> "

ALACRITTY=.alacritty.yml
ALACRITTY_CONFIG=~/${ALACRITTY}
VIM=.vim
VIM_CONFIG=~/${VIM}
I3=.i3
I3_CONFIG=~/${I3}
COLLECTION_DIR=~/work/bash_scripts/Configs_controller/collection
EXCLUDE="/home/kerl/work/bash_scripts/Configs_controller/excludes"

mode=
declare -a configs_arr

confirm () {
    read -p "$*"
    case $REPLY in
        Y|y)
            return 0
            ;;
        *) 
            return 1
            ;;
    esac
}

get_recent_file () {
    echo $(find "$*" -type f -printf '%T+ %p\n' |\
        sort -r | head -n 1 | cut -d' ' -f2)    
}

# first arg is config name, second is full config path
collect_file () {

    if (( $# != 2 )); then 
        echo "To few args for collect_file function"
        return 1
    fi

    # create directory for config collection if it's needed
    [[ ! -d $COLLECTION_DIR ]] && mkdir -p $COLLECTION_DIR

    if [[ -f $2 ]]; then # file alacritty.yml exists
        if [[ -f ${COLLECTION_DIR}/${1} &&\
             ${COLLECTION_DIR}/${1} -nt $2 ]]; then

            confirm $1: $MSG_COLNEW &&\
                cp -f $2 ${COLLECTION_DIR}/${1}

        else
            cp -f $2 ${COLLECTION_DIR}/${1}
        fi
    else 
        echo "$2 is not exist"
    fi
}

# first arg is config name, second is full config path
place_file () {

    if (( $# != 2 )); then 
        echo "To few args for place_file function"
        return 1
    fi
    #
    # create directory for config collection if it's needed
    [[ ! -d $COLLECTION_DIR ]] && mkdir -p $COLLECTION_DIR

    if [[ -f ${COLLECTION_DIR}/${1} ]]; then 
        if [[ -f $2 &&\
             $2 -nt ${COLLECTION_DIR}/${1} ]]; then

            confirm $1: $MSG_CONNEW && \
                cp -f ${COLLECTION_DIR}/${1} $2 

        else 
            cp -f ${COLLECTION_DIR}/${1} $2 
        fi
    else
        echo "There is no $1 config in the collection"
    fi
}

# first arg is config name, second is full config path
collect_dir () {
    if (( $# != 2 )); then 
        echo "To few args for collect_dir function"
        return 1
    fi
    # create directory for config collection if it's needed
    [[ ! -d $COLLECTION_DIR ]] && mkdir -p $COLLECTION_DIR

    # check is ~/.vim symbolic link 
    if [[ -L $\1 ]]; then 
        echo "$2 is a link"
        return
    fi

    if [[ -d $2 ]]; then 
        if [[ -d ${COLLECTION_DIR}/${1} ]]; then
            if [[ $(get_recent_file ${COLLECTION_DIR}/${1}) -nt \
                  $(get_recent_file $2) ]]; then

                confirm $1: $MSG_COLNEW && \
                    rsync -a --exclude-from=${EXCLUDE} --delete ${2}/ ${COLLECTION_DIR}/${1}
            else 
                rsync -a --exclude-from=${EXCLUDE} --delete ${2}/ ${COLLECTION_DIR}/${1}
            fi
        else
            mkdir ${COLLECTION_DIR}/${1}
            rsync -a --exclude-from=${EXCLUDE} ${2}/ ${COLLECTION_DIR}/${1}
        fi
    else
        echo "$2 is not exist"
    fi

}

# first arg is config name, second is full config path
place_dir () {
    if (( $# != 2 )); then 
        echo "To few args for place_dir function"
        return 1
    fi

    if [[ -L $2 ]]; then
        echo "$2 is a link"
        return
    fi

    if [[ -d ${COLLECTION_DIR}/${1} ]]; then
        if  [[ -d $2 ]]; then
            if [[ $(get_recent_file $2) -nt \
                  $(get_recent_file ${COLLECTION_DIR}/${1}) ]]; then

            confirm $1:  $MSG_CONNEW && \
                rsync -a --exclude-from=${EXCLUDE} --delete ${COLLECTION_DIR}/${1}/ ${2}

            else
            rsync -a --exclude-from=${EXCLUDE} --delete ${COLLECTION_DIR}/${1}/ ${2}
            fi
        else
            read -p "Make copy of $1 or make link? (c/l): "
            case $REPLY in
                c|C)
                    rsync -a --exclude-from=${EXCLUDE} ${COLLECTION_DIR}/${1}/ ${2}
                    ;;
                l|L)
                    ln -s ${COLLECTION_DIR}/${1} ${2}
                    ;;
                *)
                    echo "incorrect input"
                    ;;
            esac
        fi
    else
        echo "There is no $1 config in the collection"
    fi
}



while [[ -n $1 ]]; do 
    case $1 in 
        -c | --collect) 
            if [[ -z $mode ]]; then 
                mode="collect"
            else 
                echo "there can be only one mode: -c or -p"
                exit 1
            fi
            ;;
        -p | --place) 
            if [[ -z $mode ]]; then 
                mode="place"
            else 
                echo "there can be only one mode: -c or -p"
                exit 1
            fi
            ;;
        -a | --all)
            configs_arr+=( i3 )
            configs_arr+=( alacritty )
            configs_arr+=( vim )
            ;;
        --i3)
            configs_arr+=( i3 )
            ;;
        --vim)
            configs_arr+=( vim )
            ;;
        --alacritty)
            configs_arr+=( alacritty )
            ;;
        *)
            echo "Invalid parameters"
            exit 1;
            ;;
    esac
    shift
done

if (( ${#configs_arr[@]} == 0)); then
    configs_arr+=( i3 )
    configs_arr+=( alacritty )
    configs_arr+=( vim )
fi

for i in ${configs_arr[*]}; do
    case $i in 
        i3) 
            [[ $mode == "collect" ]] && \
                collect_dir $I3 $I3_CONFIG
            [[ $mode == "place" ]] && \
                place_dir $I3 $I3_CONFIG
            ;;
        vim)
            [[ $mode == "collect" ]] && \
                collect_dir $VIM $VIM_CONFIG
            [[ $mode == "place" ]] && \
                place_dir $VIM $VIM_CONFIG
            ;;
        alacritty)
            [[ $mode == "collect" ]] && \
                collect_file $ALACRITTY $ALACRITTY_CONFIG
            [[ $mode == "place" ]] && \
                place_file $ALACRITTY $ALACRITTY_CONFIG
            ;;
    esac
done
