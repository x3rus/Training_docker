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

def f_connect_dockerhost():
    """
        TODO : ajout doc f_connect_dockerhost et p-e validation try / except 

        TODO : Trapper les exceptions
    """
    # Connexion a docker
    conn = docker.Client(version='auto')
    return conn

# END  f_connect_dockerhost():

##################
####   MAIN   ####
##################

# Load configuration file
try :
    cfg = ConfigObj(CONF_FILE)
    # TODO revoir le fichier de configuration pour des entres optionel
    ImageName=cfg['IMAGE_NAME']
    ImageBaseTag=cfg['IMAGE_BASE_TAG']

except KeyError:
    print (" [ERROR] you don't have define this value in your config file : ", sys.exc_info()[1])
    print (" [ERROR] check the configuration file : ",CONF_FILE ) 
    exit(1)
except :
    print(" [ERROR] ", sys.exc_info()[0])
    print (" [ERROR] check the configuration file : ",CONF_FILE ) 
    exit(1)
    
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
container_Linux202 = cliDocker.create_container(image=ImageNameFull,
                                 hostname=ClientUsername+".x3rus.com",
                                 detach=True,
                                 name=ClientUsername+"-Linux202_"+str(datetime.date.today()),
                             )
start_output=cliDocker.start(container_Linux202)

print(start_output)
