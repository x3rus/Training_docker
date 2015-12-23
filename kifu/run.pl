#!/usr/bin/python3
# -*- coding: UTF-8 -*-
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
    print (" run.pl [-s|-f] -t \n")
    print (" -s , --select : Select Container already created ")
    print (" -f , --fresh  : start a Fresh one from the original ")
    print (" -t , --tag : start a container with a specifique Tag [Not yep implemented] ")

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
    dictLstContainers=cliDocker.containers(all=True)
    for container in dictLstContainers: 
        # Add / to feet with the output :P
        if container['Names'][0] == "/"+searchContainerName:
            return True,container

    return False,None

# END f_search_container_name(cliDocker,ContainerName)

def f_ask_name_with_validation(cliDocker,PrefixContainerName):
    """
        TODO : ajout doc pour f_ask_name_with_validation
    """

    bContainerNameIsOK =  False
    # PrefixContainerName = xerus-Linux202_base (exemple)
    print (" Please enter the new container name , the original look like : " + PrefixContainerName + "base")
    print (" You can change the last part _base ")
    while bContainerNameIsOK == False:
        sys.stdout.write(" Please complet the containername : " + PrefixContainerName )
        SufixContainerName = input().lower()
        New_containerName = PrefixContainerName + SufixContainerName
        (bContainerFound,ContainerID) = f_search_container_name(cliDocker,New_containerName)
        if bContainerNameIsOK :
            print ("container Name " + New_containerName + " already use try an other one ")
        else:
            bContainerNameIsOK = True
    
    return New_containerName

# END f_ask_name_with_validation:

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

    if len(lstContainer) == 0 :
        print ("No container for Linux202 actually available")
        return None

    # TODO : Option de 0 pour annuler :P
    bNeedSelectMenu = True
    numContainer=1
    while bNeedSelectMenu :
        numContainer=1
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
            print ("You cancel selection ")
            return None
        elif ContainerNumSelected >= 1 and ContainerNumSelected < numContainer  :
            return lstContainer[ContainerNumSelected - 1]["Names"]


# END f_select_container

def f_get_ipAddr_container(cliDocker,ContainerName):
    """
        TODO :  Doc f_get_ipAddr_container 
    """

    dct_info_container = cliDocker.inspect_container(ContainerName)
    if dct_info_container == None:
        print ("Something wierd happen it's seem the container did not start")
        return None
    else:
        return (dct_info_container["NetworkSettings"]["IPAddress"])

# END f_get_ipAddr_container

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
    elif opt in ("-t", "--tag"):
        # TODO faire la configuration pour pouvoir demarrer un autre Tag image
        raise NotImplementedError("Not yep implemented  :P ")


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
    ContainerName=f_ask_name_with_validation(cliDocker,PrefixContainerName)

# If user want select one already created
if SELECT:
    PrefixContainerName=ClientUsername+"-Linux202_"
    ContainerName=f_select_container(cliDocker,PrefixContainerName)
    if ContainerName == None:
        exit (1)
    
# Je conserve la double validation de la presence du container au cas ou le container
# serai creer par un autre voie entre temps ... 
(bContainerFound,ContainerID) = f_search_container_name(cliDocker,ContainerName)

if bContainerFound:
    #if DONTASK == False:
        #TODO a ajouter
        # ContainerName = f_ask_create_new_container_or_reuse(ContainerID)

    start_output = cliDocker.start(ContainerID)
else:
    # TODO ajouter le parametre du port 22 !! 
    container_Linux202 = cliDocker.create_container(image=ImageNameFull,
                                 hostname=ClientUsername+".example.com",
                                 detach=True,
                                 name=ContainerName,
                             )
    start_output=cliDocker.start(container_Linux202,privileged=True)

print ("Start Container name : " + ContainerName + " from img : " + ImageNameFull)
ContainerIpAdd = f_get_ipAddr_container(cliDocker,ContainerName)
if ContainerIpAdd:
    print ("The ip address of the container is : " + ContainerIpAdd)
    print (" use ssh : ssh bob@" + ContainerIpAdd )
if start_output:
    print( " Additional Info : "+ start_output)


