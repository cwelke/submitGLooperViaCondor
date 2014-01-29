#### !/usr/local/bin/bash

#set up some preliminaries
source /code/osgcode/cmssoft/cmsset_default.sh  > /dev/null 2>&1
export SCRAM_ARCH=slc5_amd64_gcc462
echo $SCRAM_ARCH

# workaround to get lcg-cp to run
export LD_LIBRARY_PATH_ORIG=$LD_LIBRARY_PATH

#scram list
echo Begin. Print self first
cat $0
echo $HOSTNAME
oDir=`pwd`
CMSSWRelease=$1
fileCfg=$2
fileIn=$3
outputDir=$4
CMS2Tag=$5
CMS2Tar=$6
jobnumber=$7

#checkout cmssw and untar the libraries and py files
scram list
scram project -n ${CMSSWRelease}_$CMS2Tag CMSSW $CMSSWRelease
if [ $? != 0 ]; then
	echo "ERROR: Failed to check out CMSSW release $CMSSWRelease. Exiting job without running."
fi
mv $CMS2Tar ${CMSSWRelease}_$CMS2Tag/
cd ${CMSSWRelease}_$CMS2Tag
tar -xzf $CMS2Tar
eval `scram runtime -sh`
if [ "${CMSSW_BASE##*/}" = "" ]; then
	echo "ERROR: Could not set up CMSSW environment. Exiting."
	exit 1
fi
cd -

filecfgname=`basename $fileCfg`

# creating a fresh directory to work out of. Less of a chance of staging out garbage
mkdir temp_runoutput
cp $filecfgname ./temp_runoutput/
cd temp_runoutput

#name of fjr
fileFjr=condor_fjr_${jobnumber}.xml

#run the ntuple maker
cmsRun -j $fileFjr $filecfgname inputFile=$fileIn
didcmsRun=$?

# fix lcg-cp library paths
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH_ORIG

#stage out
if [ $didcmsRun == 0 ]; then
	echo "cmsRun was successful. Staging out to $outputDir"
	lcg-cp -b -D srmv2 --vo cms -t 2400 --verbose file:./ntuple.root srm://bsrm-3.t2.ucsd.edu:8443/srm/v2/server?SFN=${outputDir}/unmerged/unmerged_ntuple_${jobnumber}.root
	lcg-cp -b -D srmv2 --vo cms -t 2400 --verbose file:./$fileFjr srm://bsrm-3.t2.ucsd.edu:8443/srm/v2/server?SFN=${outputDir}/res/$fileFjr
else
	echo "ERROR: cmsRunFailed. see ${outputDir}/res/$fileFjr for details "
	lcg-cp -b -D srmv2 --vo cms -t 2400 --verbose file:./$fileFjr srm://bsrm-3.t2.ucsd.edu:8443/srm/v2/server?SFN=${outputDir}/res/$fileFjr
fi

#cleanup
echo "working from directory:" 
pwd
echo
echo "Contents:" 
ls ./
echo

echo "Cleaning up."
rm -r ./*
