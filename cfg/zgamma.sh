
export workingDirectory=`pwd`
export executableScript=lib/libsh/makeBabyntuple.sh
export CMSSWRelease="CMSSW_5_3_2_patch4"
export CMS2Tag="V05-03-31"
export fileCfg=$workingDirectory/cfg/${dataSet}_cfg.py
export dataSetActual=/ZG_Inclusive_8TeV-madgraph_v2/Summer12_DR53X-PU_S10_START53_V7A-v1/AODSIM
export CMS2NtupleLocation=/hadoop/cms/store/group/snt/papers2012/Summer12_53X_MC/ZG_Inclusive_8TeV-madgraph_v2_Summer12_DR53X-PU_S10_START53_V7A-v1/V05-03-31/
export dataSet=`echo ${dataSetActual#/} | sed 's/\/AODSIM//g' | sed 's/\//_/g'`
export dataset=zg_inclusive
export isdata=false
export outputDir=/hadoop/cms/store/user/$USER/${CMSSWRelease}_${CMS2Tag}_babies/$dataSet
export CMS2Tar=CMS2CORE.tgz
