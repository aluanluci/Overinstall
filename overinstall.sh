#!/bin/env bash


#Style Text
green="\033[32m";
red="\033[31m";
yellow="\033[33m";
bold="\033[1m";
def="\033[0;0m";

#Utils Vars
name="$green$bold\n\tOverinstall v1.0.3 | Bash Version\n\n$def";
error_io="$red$bold\nError: Invalid option\n$def\n"

function Overinstall
{
    if [[ $1 && $2 ]]
    then
        package=$1
        apk_path=$2
        base=$(pm path $package | grep "base.apk" | sed "s/package://g") || return 0
        tmp_path="$(pwd)/.tmp"

        if [ ! -d $tmp_path ]
        then
            mkdir $tmp_path
        fi

        cp $apk_path "$tmp_path/base.apk"

        echo "#!/system/bin/sh" > "$tmp_path/script.sh"
        echo "until [ \"\$(getprop sys.boot_completed)\" = 1 ];do sleep 3;done;until [ -d \"/sdcard/Android\" ];do sleep 1;done;grep \"$package\" /proc/mounts | while read -r l; do echo \$l | cut -d \" \" -f 2 | sed \"s/apk.*/apk/\" | xargs -r umount -l; done;chmod 644 $tmp_path/base.apk;chown system:system $tmp_path/base.apk;chcon u:object_r:apk_data_file:s0 \"$tmp_path/base.apk\";mount -o bind \"$tmp_path/base.apk\" \"$base\";am force-stop \"$package\";" >> $tmp_path/script.sh || return 1
        
        chmod +x $tmp_path/script.sh || return 1

        cp -f $tmp_path/script.sh /data/adb/service.d/$package.sh || return 1

        su --mount-master -c $tmp_path/script.sh
        return 0
    else
        printf "$red$bold\nPlease specify package name and apk path, use -h option to get help$def\n\n"
        return 1
    fi
}

function Setup
{
    printf "\n$green$bold\r$2 Apps Package List:\n";
    pl=$(pm list packages -$1 | sed "s/package://");
    c=0;
    declare -a options

    for i in $pl;
    do
        ((c+=1));
        printf "$yellow$bold\r[$(printf '%02d' $c)]$def $i\n";
        options[$c]=$i
    done;
    printf "$yellow$bold\nSelect a package from list: $def"
    read p

    if [[ $p == "" ]] || (( $p > $c )) || [[ $p =~ [a-zA-Z] ]] 
    then
        printf "$error_io"
        return 1
    fi
    
    package_name=${options[$(printf "%0d" $p)]}
    printf "$bold$green\n[*] Package:$def $package_name\n\n"
    
    options=("Local$bold src/$def directory" "Custom path")
    c=0

    for i in "${options[@]}"
    do
        ((c+=1))
        printf "$yellow$bold[$c]$def $i\n"
    done
    printf "$yellow$bold\nWhere's the new .apk file? $def"
    read -e p

    unset $options
    
    case $p in
        "1")
            if [[ -d "apks/" ]]
            then
                apks=$(ls apks/)
                c=0
                declare -a options

                printf "$green$bold\nList of files in local src/ folder:$def\n"
                for i in "${apks[@]}"
                do
                    ((c+=1))
                    printf "$yellow$bold\a[$c]$def $i\n"
                    options[$c]=$i
                done
                msg=$(printf "$yellow$bold\nSelect an .apk from list: $def")
                read -e -p "$msg" p

                if [[ $p > $c ]] || [[ $p =~ [a-zA-Z] ]] || [[ $p == "" ]]
                then
                    printf "$error_io" 
                    return 1
                else
                    apk_path="apks/${options[$p]}"
                fi

            else
                printf "$red$bold\nError: src/ directory does not exist\n$def"
                return 1
            fi
        ;;
        "2")
            msg=$(printf "$yellow$bold\n\aInput your .apk path:$def ")
            read -e -p "$msg" p
            if [[ -f "$p" ]]
            then
                apk_path=$p
            else
                printf "$red$bold\nError: file not found$def\n\n"
                return 1
            fi
        ;;
    esac
    printf "$green$bold\n[*] APK Path:$def $apk_path\n"

    printf "$yellow$bold\nMounting...\n"
    if [ "$(Overinstall $package_name $apk_path)" == 1 ]
    then
        printf "$red$bold\nMounting error, reboot your device and try again\n$def"
    else
        printf "$green$bold\nMounted!\n$def"
    fi
}


function Main
{
    printf "$name";

    options=("Normal App" "$red\aSystem App$def");
    c=0;

    for o in "${options[@]}";
    do
        ((c+=1));
        printf "$yellow$bold\r[$c]$def $o\n";
    done;
    printf "\n$yellow$bold\rWhat type of app do you want to overinstall? $def";
    read p;
    if (( $p > $c )) || [[ $p =~ [a-zA-Z] ]] || [[ $p == "" ]]
    then
        printf "$error_io"
        return 1
    else
        case $p in
            "1")
                Setup '3' "Normal";
            ;;
            "2")
                Setup 's' "System";
            ;;
            *)
                printf "$error_io"
            ;;
        esac
    fi

}


function Help
{
    printf "$name";
    printf "Overinstall = install apps by mounting, without losing data and more.\n\n";
    printf "use: overinstall <option>\n\nOptions:\n"
    printf " --help | -h  = Show this\n"
    printf " --overinstall <package> <apk_path> | -i <package> <apk_path> = Overinstall directly with package name and apk file path of desired app\n"
    printf "\nIt's possible run without arguments too, as a simple script"
    printf "\nYou can also put your apk files inside the src folder and use them in the setup"
}


    case $1 in
        "")
        if [[ $(whoami) != "root" ]]
        then
            printf "$red$bold\nPlease run as root\n"
            exit 1
        else
            Main;
        fi
        ;;
        '--help' | '-h')
            Help;
        ;;
        '--overinstall' | '-i')
        if [[ $(whoami) != "root" ]]
        then
            printf "$red$bold\nPlease run as root\n"
            exit 1
        else
            Overinstall $2 $3;
        fi
        ;;
    esac