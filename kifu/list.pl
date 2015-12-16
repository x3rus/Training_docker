#!/usr/bin/python3
#
# Description : Script to liste the docker container for the Training
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
SHOW_ALL=False

yes_no_valid = {"yes": True, "y": True, "ye": True, "YES": True,
             "no": False, "n": False, "NO": False}

#################
###   FUNCs   ###
         
def f_usage():
    """
        TODO : Ajout de doc pour f_usage
    """
    print ("Script to list the Docker arguments availables ")
    print (" list.pl [-a]  \n")
    print (" -h : Show this messages ")
    print (" -a : Show all container include stopped container ")

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
#
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


def f_list_container(cliDocker,PrefixContainerName,ShowUpAndDown):
    """
        TODO : ajout doc pour f_lis_container 

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
                if not ShowUpAndDown:
                    if "Up" in container["Status"] or "Pause" in container["Status"]:
                        lstContainer.append(myContainer)
                else:
                        lstContainer.append(myContainer)

    if len(lstContainer) == 0 :
        print ("No container for Linux202 actually Up or Pause")
        return None

    for ctn in lstContainer:
        print (ctn['Names'] + " >>" )
        print ("        Images : " + ctn['Image'] )
        print ("        Status : " + ctn['Status'] )
        print ("        Created : " + str(ctn['Created']) )
        print ("        IP: " + f_get_ipAddr_container(cliDocker,ctn['Names']))
# END f_select_container



##################
####   MAIN   ####
##################

# Get Command line arguments
argv=sys.argv[1:]

# Parse commande Line arguments
try:
    opts, args = getopt.getopt(argv,"ha",["all"])
except getopt.GetoptError:
    f_usage()
    exit(2)
for opt, arg in opts:
    if opt == '-h':
        f_usage()
        exit()
    elif opt in ("-a", "--all"):
        # argument = arg # nothing here :D
        SHOW_ALL=True

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

f_list_container(cliDocker,PrefixContainerName,SHOW_ALL)

