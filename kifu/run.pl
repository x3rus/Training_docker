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
import getopt
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
SELECT=False
FRESH_ONE=False
ContainerID=None

yes_no_valid = {"yes": True, "y": True, "ye": True, "YES": True,
             "no": False, "n": False, "NO": False}

#################
###   FUNCs   ###
         
def f_usage():
    """
        TODO : Ajout de doc pour f_usage
    """
    print ("Script to start the Docker arguments availables ")
    print (" run.pl [-s|-f] \n")
    print (" -s , --select : Select Container already created ")
    print (" -f , --fresh  : start a Fresh one from the original ")

# END f_usage()

def f_connect_dockerhost():
    """
        TODO : ajout doc f_connect_dockerhost et p-e validation try / except 

        TODO : Trapper les exceptions
    """
    # Connexion a docker
    conn = docker.Client(version='auto')
    return conn

# END  f_connect_dockerhost():

def f_search_container_name(cliDocker,searchContainerName):
    """
        TODO : ajout doc f_search_container_name et p-e validation try / except 
        return (bContainerFound,ContainerID) 
    """
    # TODO change images pour PS method de docker
    dictLstContainers=cliDocker.containers(all=True)
    for container in dictLstContainers: 
        # Add / to feet with the output :P
        if container['Names'][0] == "/"+searchContainerName:
            print (" Found : " , container)
            return True,container

    return True,None

# END f_search_container_name(cliDocker,ContainerName)

def f_ask_name_with_validation(PrefixContainerName):
    """
        TODO : ajout doc pour f_ask_name_with_validation
    """

    # PrefixContainerName = xerus-Linux202_base (exemple)
    print (" Please enter the new container name , the original look like : " + PrefixContainerName + "base")
    print (" You can change the last part _base ")
    sys.stdout.write(" Please complet the containername : " + PrefixContainerName )
    SufixContainerName = input().lower()
    New_containerName = PrefixContainerName + SufixContainerName
    
    # TODO utiliser f_search_container_name pour voir si le nom existe deja
    # TODO rajouter une boucle pour faire plusieurs teste si le nom existe deja .... 
    
# END f_ask_name_with_validation:

##################
####   MAIN   ####
##################

# Get Command line arguments
argv=sys.argv[1:]

# Parse commande Line arguments
try:
    opts, args = getopt.getopt(argv,"hsf",["select","fresh"])
except getopt.GetoptError:
    f_usage()
    exit(2)
for opt, arg in opts:
    if opt == '-h':
        f_usage()
        exit()
    elif opt in ("-s", "--select"):
        # argument = arg # nothing here :D
        SELECT=True
    elif opt in ("-f", "--fresh"):
        FRESH_ONE=True


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

ImageNameFull=ImageName+":"+ImageBaseTag 
ClientUsername=getpass.getuser()
ContainerName=ClientUsername+"-Linux202_"+ImageBaseTag

# if freshon
if FRESH_ONE :
    PrefixContainerName=ClientUsername+"-Linux202_"
    ContainerName=f_ask_name_with_validation(PrefixContainerName)

# TODO :  a valider si refaire une recherche est encore pertinent si on a deja fait la
# validation dans f_ask_name_with_Validation....
(bContainerFound,ContainerID) = f_search_container_name(cliDocker,ContainerName)

if bContainerFound:
    if DONTASK == False:
        #TODO a ajouter
        # ContainerName = f_ask_create_new_container_or_reuse(ContainerID)
        raise NotImplementedError(" workin progress :P ")

    start_output = cliDocker.start(ContainerID)
else:
    # TODO ajouter le parametre du port 22 !! 
    container_Linux202 = cliDocker.create_container(image=ImageNameFull,
                                 hostname=ClientUsername+".x3rus.com",
                                 detach=True,
                                 name=ContainerName,
                             )
    start_output=cliDocker.start(container_Linux202)

print(start_output)

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


