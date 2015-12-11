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

#################
###   FUNCs   ###

def f_searchImagesName(dictImgs,searchImg):
    for image in dictImgs:
        if image['RepoTags'][0] == searchImg :
            print (" Found : " , image)
            return image

    return None

# FIN f_searchImagesName

#################
####   MAIN   ###

# Load configuration file
try :
    cfg = ConfigObj(CONF_FILE)
    DockerFilePATH=cfg['DOCKERFILE_PATH']
    ContainerName=cfg['CONTAINER_NAME']
    ContainerBaseTag=cfg['CONTAINER_BASE_TAG']
    dontAsk_raw=cfg['DONT_ASK_USE_DEFAULT_VALUE']

except KeyError:
    print (" [ERROR] you don't have define this value in your config file : ", sys.exc_info()[1])
    print (" [ERROR] check the configuration file : ",CONF_FILE ) 
    exit(1)
except :
    print(" [ERROR] ", sys.exc_info()[0])
    print (" [ERROR] check the configuration file : ",CONF_FILE ) 
    exit(1)
    
# dontAsk_validation value # TODO : voir pour changer la methode de validation de dontask
if dontAsk_raw == "YES" :
    DONTASK=1
elif dontAsk_raw == "yes":
    DONTASK=1
elif dontAsk_raw == "NO" :
    DONTASK=0
elif dontAsk_raw == "no":
    DONTASK=0
elif dontAsk_raw == 0:
    DONTASK=0
elif dontAsk_raw == 1:
    DONTASK=0

if not os.path.exists(DockerFilePATH) :
    print (" [ERROR] DockerFile Path don't exist please check it : ", DockerFilePATH)
    exit(1)

# Connexion a docker
cliDocker = docker.Client(version='auto')

# check if images already existe sur le systeme
# Valider que l'on veut reBuilder l'images car ceci divergera de la version sur hub.docker.com
dictLstImages = cliDocker.images()
infoImage = f_searchImagesName(dictLstImages,ContainerName+":"+ContainerBaseTag)

if infoImage == None:
    print ("Are you sure you want build a new one or use already created on hub.docker.com ?")

# Command use:
#  docker run -it --name=test_name_docker x3rus/linux202:base bash
#  docker ps
#  docker run -it --name=test_name_docker x3rus/linux202:base bash
#  docker start test_name_docker
#  docker attach test_name_docker
#  docker ps

lst_container=cliDocker.containers(all=True)
print ("TOTO " + "=" * 10)
print (lst_container)

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
    
# read configuration variables
#nom_container = cfg['CONTAINER_NAME']
#tag = cfg['CONTAINER_BASE_TAG']
