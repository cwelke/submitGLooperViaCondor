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
fileIn=$2
outputDir=$3
CMS2Tag=$4
CMS2Tar=$5
jobnumber=$6
dataset=$7
isdata=$8

#checkout cmssw and untar the libraries and py files
scram list
scram project -n ${CMSSWRelease}_$CMS2Tag CMSSW $CMSSWRelease
if [ $? != 0 ]; then
	echo "ERROR: Failed to check out CMSSW release $CMSSWRelease. Exiting job without running."
fi

mkdir ${CMSSWRelease}_$CMS2Tag/photonBabyMaker/
mkdir ${CMSSWRelease}_$CMS2Tag/jsons/
mkdir ${CMSSWRelease}_$CMS2Tag/vtxreweighting/
# mkdir ${CMSSWRelease}_$CMS2Tag/jetCorrections/
mv vtxreweight_Summer12MC_PUS10_19fb_Zselection.root ${CMSSWRelease}_$CMS2Tag/vtxreweighting/
mv Merged_190456-208686_8TeV_PromptReReco_Collisions12_goodruns.txt ${CMSSWRelease}_$CMS2Tag/jsons/
mv libmakePhotonBabies.so ${CMSSWRelease}_$CMS2Tag/photonBabyMaker/
mv runMakePhotonBabies.cc ${CMSSWRelease}_$CMS2Tag/photonBabyMaker/
# mv makePhotonBabies.cc ${CMSSWRelease}_$CMS2Tag/photonBabyMaker/
# mv makePhotonBabies.h ${CMSSWRelease}_$CMS2Tag/photonBabyMaker/


mv $CMS2Tar ${CMSSWRelease}_$CMS2Tag/src/
cd ${CMSSWRelease}_$CMS2Tag/src/
tar -xzf $CMS2Tar
# cp CMS2/NtupleMacros/CORE/jetcorr/jetCorrectionFiles/{GR_R_52_V9_*,START52_V9B} ../jetCorrections/
# tar -xzf ZHPhotonLooper.tgz
eval `scram runtime -sh`
if [ "${CMSSW_BASE##*/}" = "" ]; then
	echo "ERROR: Could not set up CMSSW environment. Exiting."
	exit 1
fi
cd ../
ln -s ./src/CMS2/NtupleMacros/CORE
ln -s ./src/CMS2/NtupleMacros/Tools
ln -s ./src/CMS2/NtupleMacros/CORE/jetcorr/jetCorrectionFiles jetCorrections

# echo "local directory contents"
# ls

# echo "jet correction files"
# ls jetCorrections

cd photonBabyMaker/

#run the ntuple maker
echo "running root -b -q \"runMakePhotonBabies.cc (\"$dataset\", \"$jobnumber\", $isdata, \"batch\" )\""
root -b -q "runMakePhotonBabies.cc (\"$dataset\", \"$jobnumber\", $isdata, \"batch\" )"
didcmsRun=$?

# fix lcg-cp library paths
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH_ORIG

echo "Contents:" 
ls ./

du -sch ntuple.root

#stage out
if [ $didcmsRun == 0 ]; then
	echo "looper was successful. Staging out to $outputDir"
	lcg-cp -b -D srmv2 --vo cms -t 2400 --verbose file:`pwd`/ntuple.root    srm://bsrm-3.t2.ucsd.edu:8443/srm/v2/server?SFN=${outputDir}/unmerged/unmerged_ntuple_${jobnumber}.root
	# lcg-cp -b -D srmv2 --vo cms -t 2400 --verbose file:`pwd`/${outFileName} srm://bsrm-3.t2.ucsd.edu:8443/srm/v2/server?SFN=$outputDir/${outFileName}
else
	echo "ERROR: looper Failed."
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
