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
import docker
import re
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
    
