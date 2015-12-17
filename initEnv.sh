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
        git status
        if [ $? -ne 0 ]; then 
            # Le repertoire existe mais git status fonctionne pas nous allons essayer de le supprimer et faire
            # le checkout
            cd ..
            rmdir $GITCLONE_DOCKERS
            f_show_msg "debug" "Tentative de suppression du répertoire "
            if [ $? -ne 0 ] ; then
                f_show_msg "error" "Répertoire $GITCLONE_DOCKERS existe mais ne contient pas un dépôt "
                f_show_msg "error" "Le répertoire ne semble pas vide Le script ne peux pas le supprimer"
                return 1
            else
                git clone $GITHUB_DOCKERS $GITCLONE_DOCKERS 
                if [ $? -ne 0 ] ;then
                    f_show_msg "error" "Probleme lors de la commande git clone , est-ce que git est installer ??"
                    f_show_msg "debug" "CMD utilise : git clone $GITHUB_DOCKERS $GITCLONE_DOCKERS "
                    return 1
                fi # validatio  git clone
            fi # validation rmdir $GITCLONE_DOCKERS
        else # else git status
            # le repertoire existe et ceci est le repo nous allons valider que nous sommes bien au dernier 
            # commit 
            git pull origin master
            if [ $? -ne 0 ] ;then
                f_show_msg "error" "Problème lors de la synchronisation avec le dépôt "
                f_show_msg "debug" " CMD utilise : git pull origin master"
                return 1
            fi # git pull origin master
        fi # git status

        cd $ORIGNAL_DIR
    else # else validation repertoire $GITCLONE_DOCKERS
        git clone $GITHUB_DOCKERS $GITCLONE_DOCKERS 
        if [ $? -ne 0 ] ;then
            f_show_msg "error" "Probleme lors de la commande git clone , est-ce que git est installer ??"
            f_show_msg "debug" "CMD utilise : git clone $GITHUB_DOCKERS $GITCLONE_DOCKERS "
            return 1
        fi
    fi # validation repertoire $GITCLONE_DOCKER

    # validation du commit en place
    cd $GITCLONE_DOCKERS
    COMMIT_VERSION=$(git log --pretty=oneline | head -1 | cut -d " " -f 1)

#    TODO : pas convaincu de la pertinence et cause problème pour le moment 
#    if [ $COMMIT_VERSION != $GIT_LAST_COMMIT ] ; then
#        f_show_msg "error" "La version utiliser ne correpond pas a celle attendu "
#        f_show_msg "info" "Valider avec le formateur que vous avez la bonne version "
#        return 1
#    fi
    cd $ORIGNAL_DIR

    return 0
} # FIN f_clone_docker_training

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


f_install_py_libs(){

  LST_LIB_2_INSTALL="docker-py configobj"
  RETURN_CODE=0

  for lib2install in $LST_LIB_2_INSTALL ; do
    f_show_msg "debug" "Installation de $lib2install"
    sudo pip install $lib2install
    if [ $? -ne 0 ] ; then
      f_show_msg "error" "Problème avec la librairie $lib2install , on continue  "
      RETURN_CODE=1
    fi
  done
} # f_install_py_libs

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

#################################
# Installation de requis python #
#################################
f_show_msg "info" "Nous allons proceder à l'installation de librairie python requis par les scripts avec pip"

f_install_py_libs
if [ $? -ne 0 ] ; then
  f_show_msg "error" "Problème lors de l'installation des librairy python est survenu !"
  f_show_msg "error" "Nous continuons mais les scripts python risque d'avoir un problème "
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

######################################
#       Download le container        #
######################################
f_show_msg "extrainfo" "Téléchargement du container "

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

exit 0
