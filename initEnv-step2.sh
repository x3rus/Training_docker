#!/bin/bash
#
# Description : 
#
# Author : Thomas Boutry <thomas.boutry@x3rus.com>
#
####################################################

##########
## VARS ##
##########

DOCKER_DIR=$HOME/Linux202/
DOCKER_DIR_tmp=$HOME/Linux202/tmp
GITHUB_DOCKERS=https://github.com/x3rus/Training_docker.git
GITCLONE_DOCKERS=$DOCKER_DIR/Training_docker
GIT_LAST_COMMIT="4e6fdb3e9dd5a507e34565c0da940dc257236a4d" #extraction git log --pretty=oneline | head -1 | cut -d " " -f 1
CONTAINER_X3="x3rus/linux202:base" 

VERBOSE=0
DEBUG=0

###########
## Funcs ##
###########

f_usage(){
    echo " Ce script permet d'authomatiser l'installation de Docker ainsi que le container "
    echo " pour la Formation GNU/Linux 202 (http://x3rus.com/moodle/), ce container sera "
    echo " utilisé pour les exercices et sessions pratique ." 
    echo ""
    echo " Utilisation : "
    echo "      -d  : Active le mode debug "
    echo "      -h  : Affiche ce message "
    echo "      -v  : Active le mode verbose"
} # f_usage

f_show_msg(){
    TYPE=$1
    MSG=$2

    case $TYPE in
        error)
            echo "[ERR] - $MSG"
            ;;
        extrainfo)
            if [ $VERBOSE -eq 1 ];then
                echo "[EXT] - $MSG"
            fi
            ;;
        debug)
            if [ $DEBUG -eq 1 ];then
                echo "[DEB] - $MSG"
            fi
            ;;
        info)
            echo "[INF] - $MSG"
            ;;
        warning)
            echo "[WARN] $MSG"
            ;;
        *)
            echo " [WARNING] function f_show_msg recieve a wrong type : $TYPE "
            echo " [WARNING] for message : $MSG"
            echo " [WARNING] please fix the script !! "
            ;;
    esac

} # END f_show_msg


f_pull_container(){
    f_show_msg "extrainfo" "pull le container $CONTAINER_X3"

    docker pull $CONTAINER_X3
    if [ $? -ne 0 ] ;then
        f_show_msg "error" "probleme  lors de l'extraction du contrainer $CONTAINER_X3"
        f_show_msg "debug" "CMD utiliser : docker pull $CONTAINER_X3"
        return 1
    fi

    f_show_msg "extrainfo" "La definition de la creation de ce container est disponible dans le repertoire"
    f_show_msg "extrainfo" " $GITCLONE_DOCKERS/ubuntu-version/Dockerfile"
    return 0

} # FIN f_pull_container

f_clean_up_tmp(){

    # Validation que la variable n'est pas vide 
    if [ ! -z $DOCKER_DIR_tmp ] ;then
        # Validation que la variable fut pas definie au repertoire de l'utilisateur HOME
        # ceci risquerai de tout supprimer les fichiers de l'utilisateur
        if [ $DOCKER_DIR_tmp != $HOME ] ; then
            rm -rf $DOCKER_DIR_tmp
            return 0
        else
            f_show_msg "info" "Woww la variable \$DOCKER_DIR_tmp est assigné au HOME de l'utilisateur"
            f_show_msg "info" "C'est passer a 2 doigts de tout supprimer ... "
            return 1
        fi
    else
        f_show_msg "error" 'La variable $DOCKER_DIR_tmp est vide ceci est bizarre '
        return 1
    fi

    f_show_msg "extrainfo" "clean up de $DOCKER_DIR_tmp realisé "
    return 0

} # FIN f_clean_up_tmp

##########
## MAIN ##
##########

# Traitement des arguments 
while getopts ":dhv" opt; do
    case $opt in
        d)
            DEBUG=1
            ;;
        h)
            f_usage
            exit 0
            ;;
        v)
            VERBOSE=1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            f_usage
            exit 1
            ;;
    esac
done

######################################
#       Download le container        #
######################################
f_show_msg "extrainfo" "Téléchargement du container "

# Switch primagy group a docker pour l'opération ceci evite d'avoir un logout / login a faire
newgrp docker
if [ $? -ne 0 ]; then
    f_show_msg "error" "Impossible de switché sous le groupe docker il est possible que le groupe existe pas"
    f_show_msg "error" "La suite risque de donner des erreurs a valider"
fi

f_pull_container
if [ $? -ne 0 ] ;then
    f_show_msg "error" "Problème lors de la récupération du containers , voir avec le formateur"
    exit 1
fi

######################################
#      Fin et un petit clean up      #
######################################

f_show_msg "extrainfo" "On arrive a la fin , un clean up pour terminer"

f_clean_up_tmp 
if [ $? -ne 0 ] ;then
    f_show_msg "error" "problème lors de la suppression de fichier temporaire "
    exit 1
fi

f_show_msg "info" "TERMINE"

f_show_msg "info" "SVP Faire un Logout  / Logout pour que tous soit parfait au niveau des groupe "

exit 0

