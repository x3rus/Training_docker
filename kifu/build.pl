#!/usr/bin/python3
#
# Description : Build Docker from the DockerFile
#   
# 
# Auteur : Boutry Thomas <thomas.boutry@x3rus.com>
# Date de création : 2015-12-10
# Licence : GPL v3.
###############################################################################

##############
## MODULES  ##

import sys
import os.path
import docker
from configobj import ConfigObj 

#################
## GLOBAL VARS ##

CONF_FILE="./kifu.conf" # conf file
DONTASK=0

yes_no_valid = {"yes": True, "y": True, "ye": True, "YES": True,
             "no": False, "n": False, "NO": False}

#################
###   FUNCs   ###

def f_search_images(connDocker,searchImg):
    """
        TODO Ajout doc f_search_images + p-e try / except
    """
    dictLstImages = connDocker.images()
    for image in dictLstImages:
        if image['RepoTags'][0] == searchImg :
            print (" Found : " , image)
            return image

    return None

# FIN f_search_images(connDocker,searchImg)

def f_connect_dockerhost():
    """
        TODO : ajout doc f_connect_dockerhost et p-e validation try / except 
    """
    # Connexion a docker
    conn = docker.Client(version='auto')
    return conn

# END  f_connect_dockerhost():

def f_query_yes_no(question, default="yes"):
    """Ask a yes/no question via raw_input() and return their answer.

    "question" is a string that is presented to the user.
    "default" is the presumed answer if the user just hits <Enter>.
        It must be "yes" (the default), "no" or None (meaning
        an answer is required of the user).

    The "answer" return value is True for "yes" or False for "no".
    REF : http://stackoverflow.com/questions/3041986/python-command-line-yes-no-input
    """
    yes_no_valid = {"yes": True, "y": True, "ye": True,
             "no": False, "n": False}
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        sys.stdout.write(question + prompt)
        choice = input().lower()
        if default is not None and choice == '':
            return yes_no_valid[default]
        elif choice in yes_no_valid:
            return yes_no_valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' "
                             "(or 'y' or 'n').\n")
# FIN query_yes_no

def f_connect_dockerhost():
    """
        TODO : f_connect_dockerhost a completer
    """
    # Connexion a docker
    conn = docker.Client(version='auto')
    return conn

# END f_connect_dockerhost() 

def f_search_images(connDocker,searchImg):
    """
        TODO : f_search_images(connDockerH,imgName)
    """
    dictlstimages = connDocker.images()
    for image in dictlstimages:
        if image['RepoTags'][0] == searchImg :
            return image

    return none

# END  f_search_images(connDockerH,imgName):

def f_ask_if_we_build(OriImgFound,OriImageName,OriImageBaseTag):
    """
        TODO: completer doc fun f_ask_if_we_build
    """

    if OriImgFound == None :
        if f_query_yes_no("Do you want build the docker or get one already build on hub.docker.com ?") :
            return (True,OriImageBaseTag)
        else:
            print ("Please use the commande : $ docker pull ", OriImageName , ":", OriImageBaseTag)
            return (False,OriImageBaseTag)
    else:
        print ("With this configuration you will overwrite the image ", OriImageName, ":", OriImageBaseTag, " already on the system ")
        if f_query_yes_no("Do you want use an other tag ? ") :
            print ("Enter the new tag to use : ")
            NewImgTag= input().lower()
            print ("Thanks so the name will be : ", OriImageName + ":" + NewImgTag)
            return (True,  NewImgTag)
        else:
            if f_query_yes_no("Do you want cancel ? "):
                print ("Ok we cancel the build ")
                return (False,OriImageBaseTag)
            else:
                print ("Like you want :D ")
                return (True ,OriImageBaseTag)
        
# END f_ask_if_we_build

##################
####   MAIN   ####
##################

# Load configuration file
try :
    cfg = ConfigObj(CONF_FILE)
    # TODO revoir le fichier de configuration pour des entres optionel
    DockerFilePATH=cfg['DOCKERFILE_PATH']
    ImageName=cfg['IMAGE_NAME']
    ImageBaseTag=cfg['IMAGE_BASE_TAG']
    dontAsk_raw=cfg['DONT_ASK_USE_DEFAULT_VALUE']

except KeyError:
    print (" [ERROR] you don't have define this value in your config file : ", sys.exc_info()[1])
    print (" [ERROR] check the configuration file : ",CONF_FILE ) 
    exit(1)
except :
    print(" [ERROR] ", sys.exc_info()[0])
    print (" [ERROR] check the configuration file : ",CONF_FILE ) 
    exit(1)
    
# dontAsk_validation value 
if dontAsk_raw in yes_no_valid: 
   DONTASK = yes_no_valid[dontAsk_raw]

if not os.path.exists(DockerFilePATH) :
    print (" [ERROR] DockerFile Path don't exist please check it : ", DockerFilePATH)
    exit(1)

# Connect to the DockerHost
cliDocker = f_connect_dockerhost()
if cliDocker == None :
    print (" [ERROR] Script unable to connect to the DockerHost: ")
    exit(1)

# Search if the image already exist
ImageNameFull=ImageName+":"+ImageBaseTag 
imgFound = f_search_images(cliDocker,ImageNameFull)

# If we have something to ask before the build
if DONTASK == False:
    (bOk2Build,final_imgTag)=f_ask_if_we_build(imgFound,ImageName,ImageBaseTag) 
else:
    (bOk2Build,final_imgTag)=(True,ImageBaseTag)

if bOk2Build :
    print ("So we build : ", ImageName + ":" + final_imgTag)
    exit (0)
else:
    print (" Stop all")
    exit (0)

    


# Command use:
#  docker run -it --name=test_name_docker x3rus/linux202:base bash
#  docker ps
#  docker run -it --name=test_name_docker x3rus/linux202:base bash
#  docker start test_name_docker
#  docker attach test_name_docker
#  docker ps

#lst_container=cliDocker.containers(all=True)
#print ("TOTO " + "=" * 10)
#print (lst_container)

# Visualisation des modification
# docker diff test_name_docker
#
# C /root
# A /root/.bash_history
# A /root/test_name_docker

# TODO ajouter de la validation de realisation 
#ContainerNameFull=ContainerName+":"+ContainerBaseTag
# !!! BUILD CONTAINER !!!
#outputBuild = cliDocker.build(path=DockerFilePATH,tag=ContainerNameFull)
#for line in outputBuild:
#    print (line)
    
# TODO: ajouter la restriction avec DONTASK
#if DONTASK :
#else :
#
