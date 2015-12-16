#!/usr/bin/python3
#
# Description : Script to stop and delete the docker container for the Training
# linux 202
#   
# 
# Auteur : Boutry Thomas <thomas.boutry@x3rus.com>
# Date de création : 2015-12-16
# Licence : GPL v3.
###############################################################################

##############
## MODULES  ##

import sys
import getopt
import getpass
import os.path
import docker
import re
from configobj import ConfigObj 

##################
## GLOBAL VARS ##

CONF_FILE="./kifu.conf" # conf file
WANT_DELETE=False

yes_no_valid = {"yes": True, "y": True, "ye": True, "YES": True,
             "no": False, "n": False, "NO": False}

#################
###   FUNCs   ###
         
def f_usage():
    """
        TODO : Ajout de doc pour f_usage
    """
    print ("Script to start the Docker arguments availables ")
    print (" stop_destroy.pl [-d]  \n")
    print (" -d , --destroy : Option to delete a container")

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

def f_select_container(cliDocker,PrefixContainerName):
    """
        TODO : ajout doc pour f_select_container 
    """
    dictLstContainers=cliDocker.containers(all=True)
    lstContainer = []
    for container in dictLstContainers:
        if PrefixContainerName in container['Names'][0]:
            myContainer = {}
            myContainer['Created'] = container['Created']
            myContainer['Image'] = container['Image']
            myContainer['Names'] = re.sub('/','',container['Names'][0]) # remove / caractere
            myContainer['Ports'] = container['Ports']
            myContainer['Status'] = container['Status']
            lstContainer.append(myContainer)


    # TODO : Option de 0 pour annuler :P
    bNeedSelectMenu = True
    numContainer=1
    while bNeedSelectMenu :
        for oneContainer in lstContainer:
            # TODO avoir un meilleur formatage 
            # TODO avoir un visualisation de la date plutot que le unix timestamp
            # TODO avoir un menu (header) pour les colonnes 
            print ("["+str(numContainer)+"] "+oneContainer["Image"]+" "+oneContainer["Names"]+
                   " "+str(oneContainer["Created"])+" "+oneContainer["Status"])
            numContainer =  numContainer + 1
        sys.stdout.write(" Please Select the container (0 = CANCEL): " )
        ContainerNumSelected = int(input())
        if ContainerNumSelected == 0:
            bNeedSelectMenu = False
            return None
        elif ContainerNumSelected >= 1 and ContainerNumSelected < numContainer  :
            return lstContainer[ContainerNumSelected - 1]["Names"]


# END f_select_container

##################
####   MAIN   ####
##################

# Get Command line arguments
argv=sys.argv[1:]

# Parse commande Line arguments
try:
    opts, args = getopt.getopt(argv,"hd",["destroy"])
except getopt.GetoptError:
    f_usage()
    exit(2)
for opt, arg in opts:
    if opt == '-h':
        f_usage()
        exit()
    elif opt in ("-d", "--destroy"):
        # argument = arg # nothing here :D
        WANT_DELETE=True
        raise NotImplementedError("Not yep implemented  :P ")


# Load configuration file
try :
    cfg = ConfigObj(CONF_FILE)
    # TODO revoir le fichier de configuration pour des entres optionel

except KeyError:
    print (" [ERROR] you don't have define this value in your config file : ", sys.exc_info()[1])
    print (" [ERROR] check the configuration file : ",CONF_FILE ) 
    exit(1)
except :
    print(" [ERROR] ", sys.exc_info()[0])
    print (" [ERROR] check the configuration file : ",CONF_FILE ) 
    exit(1)
 
cliDocker = f_connect_dockerhost()
ClientUsername=getpass.getuser()
PrefixContainerName=ClientUsername+"-Linux202_"
ContainerName=f_select_container(cliDocker,PrefixContainerName)

if ContainerName == None:
    print ("You cancel selection ")
    exit (1)
else:
    raise NotImplementedError("Not yep implemented  :P ")
    # remove_container
    # stop
 
