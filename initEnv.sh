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
GIT_LAST_COMMIT="0069a2b2b097a217b6aa1b631d1af29ee48e2430" #extraction git log --pretty=oneline | head -1 | cut -d " " -f 1

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

f_install_docker(){
    # TODO : Function f_install_docker non tester car docker deja present ! a valider 
    f_show_msg "info" "Process with the docker installation [y/N] ? "
    read InstallDocker

    if [ $InstallDocker = "Y" -o $InstallDocker = "y" ]; then
        wget -O $DOCKER_DIR_tmp/deploy_docker.sh -q https://get.docker.com/        
        if [ $? -ne 0 ] ;then
            f_show_msg "error" "Impossible de recuperer le script de deployement de docker "
            f_show_msg "debug" "CMD utilisez : wget -O $DOCKER_DIR_tmp/deploy_docker.sh -q https://get.docker.com/ "
            return 1
        fi

        f_show_msg "extrainfo" "Execution du script de deployement de docker "
        bash $DOCKER_DIR_tmp/deploy_docker.sh
        if [ $? -ne 0 ];then
            f_show_msg "error" "Probleme lors de l'execution du script de deployement de docker precedement downloader"
            f_show_msg "debug" "CMD utilisez : bash $DOCKER_DIR_tmp/deploy_docker.sh "
            return 1
        fi
    fi

    f_show_msg "extrainfo" "Docker devrait être installer a cette étape "
    return 0
} # END f_install_docker 

f_create_dir(){
    f_show_msg "extrainfo" "Création des répertoires $DOCKER_DIR "
    if [ -d $DOCKER_DIR ]; then
        f_show_msg "debug" "Répertoire $DOCKER_DIR existe déjà "
        if [ ! -w $DOCKER_DIR ] ; then
            f_show_msg "error" "Répertoire $DOCKER_DIR existe mais l'usager ne peut pas écrire"
            return 1
        fi
    else
        # Le repertoire n'existe pas Creation du répertoire
        mkdir -p $DOCKER_DIR
        if [ $? -ne 0 ]; then
            f_show_msg "error" "Impossible de créer le répertoire $DOCKER_DIR"
            return 1 
        fi
        mkdir -p $DOCKER_DIR_tmp
        if [ $? -ne 0 ];then
            f_show_msg "error" "Impossible de créer le répertoire $DOCKER_DIR_tmp"
            return 1 
        fi
    fi

    f_show_msg "debug" "$DOCKER_DIR et $DOCKER_DIR_tmp maintenant present ! "
    return 0
} # END f_create_dir

f_clone_docker_training() {

    f_show_msg "extrainfo" "Clone le git disponible du GITCLONE_DOCKERS dans le répertoire $DOCKER_DIR"
    ORIGNAL_DIR=$PWD
    if [ -d $GITCLONE_DOCKERS ] ;then
        cd $GITCLONE_DOCKERS
        # TODO a completer ICI le script !! 
        git status
        git log --pretty=oneline | head -1 | cut -d " " -f 1
        cd $ORIGNAL_DIR
    fi

    git clone $GITHUB_DOCKERS $GITCLONE_DOCKERS 
    if [ $? -ne 0 ] ;then
        f_show_msg "error" "Probleme lors de la commande git clone , est-ce que git est installer ??"
        f_show_msg "debug" "CMD utilise : git clone $GITHUB_DOCKERS $GITCLONE_DOCKERS "
        return 1
    fi

    return 0
}

# 1. Installation de Docker
# 2. Checkout du Docker File
# 3. Création d'une images de base
# 4. Checkout des scripts de traitement

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

#######################################
# Creation des repertoires de travail # 
#######################################
f_create_dir
RETURN_CREATE_DIR=$?

if [ $RETURN_CREATE_DIR -ne 0 ]; then
    exit $RETURN_CREATE_DIR
fi


##########################
# Installation de Docker #
##########################

# Realisation de l'installation si l'installation pas déjà réalisé.
f_show_msg "extrainfo" "Validation si docker est déjà installer"

OUT=$(docker --version)
if [ $? -eq 0 ] ; then
    f_show_msg "extrainfo" "Docker found : $OUT "
else
    f_install_docker
    if [ $? -ne 0 ]; then
        f_show_msg "error" "Problème lors de l'installation de Docker :( , il faut corriger le probleme pour continuer"
        exit 1
    fi
fi


######################################
# CheckOut des containers et scripts #
######################################
f_show_msg "extrainfo" "Téléchargement des fichiers de description des dockers" 

f_clone_docker_training
if [ $? -ne 0 ] ;then
    f_show_msg "error" "Problème lors de la récupération des containers et scripts voir avec le formateur"
    exit 1
fi
