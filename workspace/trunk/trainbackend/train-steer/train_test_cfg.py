
class trainconfig:
	class mainConfig:
		id = 1
		debugLevel = 0
		outputFiles = ["file1.root"]
		excludeFiles = []
		additionalPackages = []
		globalVariables = []
		group = "OFFLINE"
		name = "TestTrain"
	class runConfig: 
		scramArchitcture = "slc5_amd64_gcc481"
		release = "CMSSW_7_2_0_pre6"
		releasePath = "/cvmfs/cms.cern.ch/slc5_amd64_gcc481/cms/cmssw/CMSSW_7_2_0_pre6"
		dataSetName = ""
		testFileNumbers = "0"
		runId = 1
		created = -1
		testPath = "."
		crabTask = ""
		test = False
		submitToGrid = True
			
		 
	class wagons:
		class wagon1:
			wagonName = "testWagon1"
			username = "jschulte"
			cmsCommand = "cmsDriver.py"
			macroPath  = "TTbar_Tauola_13TeV_cfi"
			parameters = "--conditions=MCRUN2_72_V0A:All --fast  -n 10 --eventcontent FEVTDEBUGHLT -s GEN,SIM,RECO,EI,HLT:@relval --datatier GEN-SIM-DIGI-RECO --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1 --magField 38T_PostLS1 --no_exec"
			outputFile = "file1.root"
			
