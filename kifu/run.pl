#!/usr/bin/python3
#
# Description : Script to start the docker container for the training
# Linux 202 
# 
# Auteur : Boutry Thomas <thomas.boutry@x3rus.com>
# Date de création : 2015-12-14
# Licence : GPL v3.
###############################################################################

##############
## MODULES  ##

import sys
import os.path
import getpass
import docker
import re
import datetime
import ast
from configobj import ConfigObj 

##################
## GLOBAL VARS ##

CONF_FILE="./kifu.conf" # conf file
DONTASK=0
ContainerID=None

yes_no_valid = {"yes": True, "y": True, "ye": True, "YES": True,
             "no": False, "n": False, "NO": False}

#################
###   FUNCs   ###

def f_connect_dockerhost():
    """
        TODO : ajout doc f_connect_dockerhost et p-e validation try / except 

        TODO : Trapper les exceptions
    """
    # Connexion a docker
    conn = docker.Client(version='auto')
    return conn

# END  f_connect_dockerhost():

def f_search_container_name(cliDocker,ContainerName):
    """
        TODO : ajout doc f_search_container_name et p-e validation try / except 
        return (bContainerFound,ContainerID) 
    """
    # TODO change images pour PS method de docker
    dictLstImages = cliDocker.images()
    for image in dictLstImages:
        print(image)
#        if image['RepoTags'][0] == searchImg :
#            print (" Found : " , image)
#            return image

    return True,"87878"

# END f_search_container_name(cliDocker,ContainerName)

##################
####   MAIN   ####
##################

# Load configuration file
try :
    cfg = ConfigObj(CONF_FILE)
    # TODO revoir le fichier de configuration pour des entres optionel
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

cliDocker = f_connect_dockerhost()

##############
#### NOTE  ###
# Gestion de paramètre 
#   -s == selection des containers dispo
#   -f == start fresh one 
#   -o == oneTime
# Validation des container disponible avec L'image (si option selection)
# Offire le choix de container a demarrer (si option selection)
# Demander le nom du container pour l'utilisation future
# (optionel ) definition de port et mountbind

# 1. Demarrage de l'image avec le container username-date
# 2. Gestion des paramètre
# 3. SNAPSHOT - autre script


ImageNameFull=ImageName+":"+ImageBaseTag 
ClientUsername=getpass.getuser()
ContainerName=ClientUsername+"-Linux202_"+ImageBaseTag

# TODO : faire une recherche pour le nom du container avant tentative de creation
(bContainerFound,ContainerID) = f_search_container_name(cliDocker,ContainerName)

exit(0)

container_Linux202 = cliDocker.create_container(image=ImageNameFull,
                                 hostname=ClientUsername+".x3rus.com",
                                 detach=True,
                                 name=ContainerName,
                             )
start_output=cliDocker.start(container_Linux202)

print(start_output)
