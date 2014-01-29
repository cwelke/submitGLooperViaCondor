import sys, os
sys.path.append( os.getenv("CMSSW_BASE") + "/src/CMS2/NtupleMaker/test" )
from CMS2.NtupleMaker.RecoConfiguration2012_cfg import *

# Global Tag
process.GlobalTag.globaltag = "START53_V7A::All"

# Input source
from FWCore.ParameterSet.VarParsing import VarParsing
options = VarParsing ('python')
options.register (
    'inputFile'
    ,''
    ,VarParsing.multiplicity.singleton
    ,VarParsing.varType.string
    ,"Run this on real data"
    )
options.parseArguments()
process.source.fileNames = cms.untracked.vstring('root://xrootd.unl.edu/' + options.inputFile)

# control max events for testing
process.maxEvents.input = 10 


# Output
process.out = cms.OutputModule(
        "PoolOutputModule",
        fileName     = cms.untracked.string('ntuple.root'),
        dropMetaData = cms.untracked.string("NONE")
)
process.outpath      = cms.EndPath(process.out)

# Branches
process.out.outputCommands = cms.untracked.vstring( 'drop *' )
process.out.outputCommands.extend(cms.untracked.vstring('keep *_*Maker*_*_CMS2*'))
process.out.outputCommands.extend(cms.untracked.vstring('drop *_cms2towerMaker*_*_CMS2*'))
process.out.outputCommands.extend(cms.untracked.vstring('drop CaloTowers*_*_*_CMS2*'))

#
process.cms2WithEverything = cms.Sequence( process.ak5PFJets * process.kt6PFJets * process.cms2CoreSequence * process.cms2PFNoTauSequence * process.cms2GENSequence )
process.cms2WithEverything.remove(process.jptMaker)
process.cms2WithEverything.remove(process.hypTrilepMaker)
process.cms2WithEverything.remove(process.hypQuadlepMaker)
process.eventMaker.datasetName                   = cms.string("/SMS-T6ttHH_2J_mStop2-325to475_mStop-175to325_TuneZ2star_8TeV-madgraph-tauola/Summer12-START53_V19_FSIM-v1/AODSIM")
process.eventMaker.CMS2tag                       = cms.string("V05-03-31")
process.p                  = cms.Path( process.cms2WithEverything )

#
process.MessageLogger.cerr.FwkReport.reportEvery = 1000
process.eventMaker.isData                        = cms.bool(False)
process.luminosityMaker.isData                   = process.eventMaker.isData

#Slim CMS2
from CMS2.NtupleMaker.SlimCms2_cff import slimcms2
process.out.outputCommands.extend(slimcms2)
process.sParmMaker.vsparms = cms.untracked.vstring(
"mstop",
"mlsp"
) # list of sparm parameters, be sure it is the same size as the number of parameter in the files
process.cms2WithEverything.replace( process.eventmakers, process.eventmakerswsparm ) #adds the sparm producer in to the sequence
process.cms2WithEverything.remove( process.cms2HBHENoiseFilterResultProducer ) #need to remove this produce for fastsim
