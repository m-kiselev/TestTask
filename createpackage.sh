#!/bin/sh

PACKAGE_NAME="TestTask"
PACKAGE_VERSION="0.1"
TEMP_DIR="/tmp"
SOURCE_DIR=''
JAR_FILE=''


#=== FUNCTION ================================================================
#        NAME: usage
# DESCRIPTION: Print usage info
#=============================================================================
usage()
{
    echo "
Usage: $0 <directory with project>   
"
}


#=== FUNCTION ================================================================
#        NAME: checkRootRight
# DESCRIPTION: Check - this script must run as root
#=============================================================================
checkRootRight()
{
    local user=`whoami`
    if [ "$user" != "root" ] ; then
        echo
        echo "ERROR: This script must be run as the root user or by using sudo!"
        echo
        exit 1
    fi
}

#=== FUNCTION ================================================================
#        NAME: checkThirdParty
# DESCRIPTION: Verify whether the installed Java and Maven
#=============================================================================
checkThirdParty() 
{
    if [ `which java` = "" ]; then
	echo "ERROR: JRE not Installed..!";
        exit 1;
    fi 
    if [ `which mvn` = "" ]; then
	echo "ERROR: Maven not Installed..!";
        exit 1;
    fi 
}

#=== FUNCTION ================================================================
#        NAME: checkRunScript
# DESCRIPTION: This function makes the test: script is running at the moment.
#=============================================================================
checkRunScript()
{
    local pid=`ps -ef | grep $0 | grep -v grep | grep -v $$ | awk '{ print $2; }'`

    if [ "$pid" != "" ]; then
        echo
        echo "ERROR: $0 is already running"
        echo
        exit 1
    fi
}


###############################################################################
## MAIN
###############################################################################
if [ $# -ne 1 ]; then
    echo "ERROR: Incorrect parameters."
    usage
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "ERROR: Directory does not exist."
    usage
    exit 1
fi

checkRootRight
checkThirdParty
#checkRunScript

cd "$1"
SOURCE_DIR=$PWD

echo
echo "***************************************"
echo "Starting $0 script..."
echo "***************************************"


# create deb infrastructure
echo "Creating deb infrastructure..."
mkdir -p $TEMP_DIR/debian/DEBIAN
mkdir -p $TEMP_DIR/debian/lib
mkdir -p $TEMP_DIR/debian/bin
mkdir -p $TEMP_DIR/debian/usr/share/applications
mkdir -p $TEMP_DIR/debian/usr/share/doc/$PACKAGE_NAME

# copy meta data files
cp control $TEMP_DIR/debian/DEBIAN
cp postinst $TEMP_DIR/debian/DEBIAN
#cp preinst $TEMP_DIR/debian/DEBIAN


# copy other files
cp test-task.sh $TEMP_DIR/debian/bin

# build jar file
echo "Building jar file..."
mvn clean package
JAR_FILE=`find target/ -name *.jar`
cp $JAR_FILE $TEMP_DIR/debian/lib/TestTask.jar

chown -R root $TEMP_DIR/debian/
chgrp -R root $TEMP_DIR/debian/

# build bed package
cd $TEMP_DIR/
dpkg --build debian
fileName=$SOURCE_DIR/$PACKAGE_NAME-$PACKAGE_VERSION.deb
mv debian.deb $fileName
rm -r $TEMP_DIR/debian

echo "***************************************"
echo "Build finished. $fileName file created"
echo "***************************************"
