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
##    FUNCS    ##
def f_query_yes_no(question, default="yes"):
    """Ask a yes/no question via raw_input() and return their answer.

    "question" is a string that is presented to the user.
    "default" is the presumed answer if the user just hits <Enter>.
        It must be "yes" (the default), "no" or None (meaning
        an answer is required of the user).

    The "answer" return value is True for "yes" or False for "no".
    REF : http://stackoverflow.com/questions/3041986/python-command-line-yes-no-input
    """
    valid = {"yes": True, "y": True, "ye": True,
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
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' "
                             "(or 'y' or 'n').\n")
# FIN query_yes_no

def f_connect_dockerhost():
    """
        TODO : f_connect_dockerhost a completer
    """
    connDockerHost = True
    return connDockerHost
# END f_connect_dockerhost() 

def f_search_images(connDockerH,imgName):
    """
        TODO : f_search_images(connDockerH,imgName)
    """
    imgFound = True
    return imgFound

#################
####   MAIN   ###

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

# Connect to the DockerHost
cliDocker = f_connect_dockerhost()
if cliDocker == None :
    print (" [ERROR] Script unable to connect to the DockerHost: ")
    exit(1)

# Search if the image already exist
ImageNameFull=ImageName+":"+ImageBaseTag 
imgFound = f_search_images(cliDocker,ImageNameFull)

if imgFound == None :
    if f_query_yes_no("Do you want build the docker or get one already build on hub.docker.com ?") :
        print ("Let's go to build the new one :D")
    else:
        print ("Good Choice :D")
else:
    print ("With this configuration you will overwrite the image ", ImageName , " already on the system ")
    if f_query_yes_no("Do you want use an other tag ? ") :
        print ("Enter the new name to use : ")
        #TODO a completer pour l'entre du nouveau tag
    else:
        if f_query_yes_no("Do you want cancel ? "):
            print ("Good Choice :D")
        else:
            print ("Like you want :D ")
        



# si l'images est présente 
#   # valider si on wipe l'existant pour la nouvelle
# si l'images n'est pas present 
#   # valider si on build ou download depuis hub.docker
    
# read configuration variables
#nom_container = cfg['IMAGE_NAME']
#tag = cfg['IMAGE_BASE_TAG']
