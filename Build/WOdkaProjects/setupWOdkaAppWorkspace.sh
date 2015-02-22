#!/bin/bash
ROOT="$WORKSPACE/Root"
TB_PROJECT="woproject.jar"
JOB_ROOT="${WORKSPACE}/../.."
FRAMEWORKS_REPOSITORY="${JENKINS_HOME}/TreasureBoatFrameworksRepository"
WONDEREXTENSIONSLABORATORY="WonderExtensionLaboratory"

echo "Project Name: WOdka LAB Framework"

#
# Configure the environment based on the platform information.
#
# Expected uname values:
#   Darwin
#   Mac OS
#   Rhapsody  (this is for things like JavaConverter, which need to run on Mac OS X Server 1.2)
#   *Windows* (this prints out an error message)
#   *winnt*   (ditto)
#
# Everything else is treated as "UNIX", the default.
#
PLATFORM_NAME="`uname -s`"

if [ "${PLATFORM_NAME}" = "" ]; then
	echo "${SCRIPT_NAME}: Unable to access uname executable!  Terminating."
	echo "If you are running on Windows, Stop it! This script isn't Windows compatible"
	exit 1
fi

case "${PLATFORM_NAME}" in
    "Darwin")   PLATFORM_DESCRIPTOR="MacOS"
                	  PLATFORM_TYPE="Darwin"
                ;;
    "Mac OS")   PLATFORM_DESCRIPTOR="MacOS"
                	  PLATFORM_TYPE="Darwin"
                ;;
    "Rhapsody") PLATFORM_DESCRIPTOR="MacOS"
                	  PLATFORM_TYPE="Rhapsody"
                ;;
    *Windows*)  echo "Windows?! Really?!! Shesh. This script only works with MacOS/Linux/UNIX. Terminating."
                exit 1
                ;;
    *winnt*)    echo "Windows?! Really?!! Shesh. This script only works with MacOS/Linux/UNIX. Terminating."
                exit 1
                ;;
    *)          PLATFORM_DESCRIPTOR="UNIX"
                	  PLATFORM_TYPE="Other"
                ;;
esac
echo "            Platform Type: ${PLATFORM_TYPE}"

#
# Depending upon the platform, provide default values for the path abstractions
#
if [ "${PLATFORM_TYPE}" = "Rhapsody" ]; then
    LOCAL_PATH_PREFIX="/Local"
    SYSTEM_PATH_PREFIX="/System"
elif [ "$PLATFORM_TYPE" = "Darwin" ]; then
    LOCAL_PATH_PREFIX=""
    SYSTEM_PATH_PREFIX="/System"
else
    LOCAL_PATH_PREFIX="/Local"
    SYSTEM_PATH_PREFIX=""
fi
echo "        Local Path Prefix: ${LOCAL_PATH_PREFIX}"
echo "       System Path Prefix: ${SYSTEM_PATH_PREFIX}"

	  WEBOBJECTS_ROOT_IN_FRAMEWORKS_REPOSITORY="${FRAMEWORKS_REPOSITORY}/WebObjects/543${SYSTEM_PATH_PREFIX}"
	WO_JAVA_APPS_ROOT_IN_FRAMEWORKS_REPOSITORY="${WEBOBJECTS_ROOT_IN_FRAMEWORKS_REPOSITORY}/Library/WebObjects/JavaApplications"
			  WOTASKD_IN_FRAMEWORKS_REPOSITORY="${WO_JAVA_APPS_ROOT_IN_FRAMEWORKS_REPOSITORY}/wotaskd.woa"
WEBOBJECTS_FRAMEWORKS_IN_FRAMEWORKS_REPOSITORY="${WEBOBJECTS_ROOT_IN_FRAMEWORKS_REPOSITORY}/Library/Frameworks"

		   WODKA_ROOT_IN_FRAMEWORKS_REPOSITORY="${FRAMEWORKS_REPOSITORY}/WOdka"
	 WODKA_FRAMEWORKS_IN_FRAMEWORKS_REPOSITORY="${WODKA_ROOT_IN_FRAMEWORKS_REPOSITORY}/Library/Frameworks"

				 WO_SYSTEM_ROOT_FOR_THIS_BUILD="${ROOT}${SYSTEM_PATH_PREFIX}"
		   WO_SYSTEM_FRAMEWORKS_FOR_THIS_BUILD="${WO_SYSTEM_ROOT_FOR_THIS_BUILD}/Library/Frameworks"
			  WO_JAVA_APPS_ROOT_FOR_THIS_BUILD="${WO_SYSTEM_ROOT_FOR_THIS_BUILD}/Library/WebObjects/JavaApplications"
			   WO_BOOTSTRAP_JAR_FOR_THIS_BUILD="${WO_JAVA_APPS_ROOT_FOR_THIS_BUILD}/wotaskd.woa/WOBootstrap.jar"

				  WO_LOCAL_ROOT_FOR_THIS_BUILD="${ROOT}${LOCAL_PATH_PREFIX}"
			WO_LOCAL_FRAMEWORKS_FOR_THIS_BUILD="${WO_LOCAL_ROOT_FOR_THIS_BUILD}/Library/Frameworks"
				  WO_EXTENSIONS_FOR_THIS_BUILD="${WO_LOCAL_ROOT_FOR_THIS_BUILD}/Library/WebObjects/Extensions"
				   WO_APPS_ROOT_FOR_THIS_BUILD="${WO_LOCAL_ROOT_FOR_THIS_BUILD}/Library/WebObjects/Applications"


# Make sure the Libraries folder exists
mkdir -p ${WORKSPACE}/Libraries

# Cleanout the Root directory of the project from the last build
rm -rf ${ROOT}

# Look for and link to the WOBootstrap.jar
echo " "
echo "Look for: ${WOTASKD_IN_FRAMEWORKS_REPOSITORY}"
if [ -e "${WOTASKD_IN_FRAMEWORKS_REPOSITORY}" ]; then
	mkdir -p ${WO_JAVA_APPS_ROOT_FOR_THIS_BUILD}
	echo "    Found wotaskd.woa in the Framworks Repository."
	echo "        Linking: ln -sfn ${WOTASKD_IN_FRAMEWORKS_REPOSITORY}"
	echo "                         ${WO_JAVA_APPS_ROOT_FOR_THIS_BUILD}"
	(ln -sfn ${WOTASKD_IN_FRAMEWORKS_REPOSITORY} ${WO_JAVA_APPS_ROOT_FOR_THIS_BUILD})
else
	echo "    WOBootstrap.jar NOT FOUND!"
	echo "        This build cannot run without it. Verify that WebObjects has been installed"
	echo "        with WOJenkins and the WOJenkins installWebObjects.sh script is using"
	echo "        ${FRAMEWORKS_REPOSITORY}"
	echo "        for its FRAMEWORKS_REPOSITORY variable."
	exit 1
fi

# Link to the Frameworks that are on the classpath of this project.
# (This does not copy the frameworks, it just links to them so it is very fast)

mkdir -p ${WO_EXTENSIONS_FOR_THIS_BUILD}

echo "Link to ${TB_PROJECT} so Ant can build the WO project."
mkdir -p ${ROOT}/lib
cp ${FRAMEWORKS_REPOSITORY}/TBProject/${TB_PROJECT} ${ROOT}/lib/${TB_PROJECT}

# Setup Directories for System
mkdir -p "${WO_SYSTEM_ROOT_FOR_THIS_BUILD}/Library"
ln -sfn ${WEBOBJECTS_FRAMEWORKS_IN_FRAMEWORKS_REPOSITORY} ${WO_SYSTEM_FRAMEWORKS_FOR_THIS_BUILD}

# Setup Directories for Local Frameworks
mkdir -p ${WO_LOCAL_FRAMEWORKS_FOR_THIS_BUILD}

# Get all the Projects that have been checked out as part of this job
PROJECTS=`ls ${WODKA_FRAMEWORKS_IN_FRAMEWORKS_REPOSITORY}/`

# Step through all wodka Frameworks and create a link
for PROJECT in $PROJECTS; do
	echo "processing ${PROJECT} :"
	echo "        Linking: ln -sfn ${WODKA_FRAMEWORKS_IN_FRAMEWORKS_REPOSITORY}/${PROJECT}"
	echo "                         ${WO_LOCAL_FRAMEWORKS_FOR_THIS_BUILD}"
	ln -sfn ${WODKA_FRAMEWORKS_IN_FRAMEWORKS_REPOSITORY}/${PROJECT} ${WO_LOCAL_FRAMEWORKS_FOR_THIS_BUILD}
done

# Create Template Folder (WOFrameworksRepository/WOdka/Library/Templates)
echo "create and copy Compiler Templates for App's"
mkdir -p ${WORKSPACE}/${WONDEREXTENSIONSLABORATORY}/WOdkaTemplates/Templates
cp ${WODKA_ROOT_IN_FRAMEWORKS_REPOSITORY}/Library/Templates/common-framework.xml ${WORKSPACE}/${WONDEREXTENSIONSLABORATORY}/WOdkaTemplates/Templates/common-framework.xml 
cp ${WODKA_ROOT_IN_FRAMEWORKS_REPOSITORY}/Library/Templates/common-app.xml ${WORKSPACE}/${WONDEREXTENSIONSLABORATORY}/WOdkaTemplates/Templates/common-app.xml 
cp ${WODKA_ROOT_IN_FRAMEWORKS_REPOSITORY}/Library/Templates/${TB_PROJECT} ${WORKSPACE}/${WONDEREXTENSIONSLABORATORY}/WOdkaTemplates/Templates/${TB_PROJECT} 

echo "Setup ${ROOT}/jenkins.build.properties for Ant to use for building"
cat > ${ROOT}/jenkins.build.properties << END
# DO NOT EDIT THIS FILE!!!
#
# This file was dynamically generated by
# ${WORKSPACE}/WOJenkins/Build/WonderProjects/WorkspaceSetupScripts/setupWOdkaWorkspace.sh
# based on values defined in the "${JOB_NAME}" Jenkins job and will be overwritten the next time
# the job is run.
#
# Changes to the job can be made by opening ${JOB_URL}/configure in a web browser.

wo.system.root=${WO_SYSTEM_ROOT_FOR_THIS_BUILD}
wo.system.frameworks=${WO_SYSTEM_FRAMEWORKS_FOR_THIS_BUILD}

wo.local.root=${WO_LOCAL_ROOT_FOR_THIS_BUILD}
wo.local.frameworks=${WO_LOCAL_FRAMEWORKS_FOR_THIS_BUILD}

wo.extensions=${WO_EXTENSIONS_FOR_THIS_BUILD}

wo.bootstrapjar=${WO_BOOTSTRAP_JAR_FOR_THIS_BUILD}
wo.apps.root=${WO_APPS_ROOT_FOR_THIS_BUILD}

wolips.properties=${ROOT}/jenkins.build.properties

ant.build.javac.target=${JAVA_COMPATIBILITY_VERSION}
END

if [ "$BUILD_TYPE" == "Test Build" ]; then
cat ${ROOT}/jenkins.build.properties > ${ROOT}/jenkins.build.properties.temp1
cat > ${ROOT}/jenkins.build.properties.temp2 << END

embed.Local=false
embed.Project=false
embed.System=false
embed.Network=false
END
cat ${ROOT}/jenkins.build.properties.temp1 ${ROOT}/jenkins.build.properties.temp2 > ${ROOT}/jenkins.build.properties
rm ${ROOT}/jenkins.build.properties.*
fi

# Backward Compatibility!
echo "Create link for backward compatibility with old build.properties file name since old build jobs will still be pointing to it."
echo "ln -sfn ${ROOT}/jenkins.build.properties ${ROOT}/build.properties"
(ln -sfn ${ROOT}/jenkins.build.properties ${ROOT}/build.properties)
