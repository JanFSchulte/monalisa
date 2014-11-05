
		TEMPVAR=`pwd`
        
        export SCRAM_ARCH=slc5_amd64_gcc481
        
        source /cvmfs/cms.cern.ch/cmsset_default.sh
		
		cd /cvmfs/cms.cern.ch/slc5_amd64_gcc481/cms/cmssw/CMSSW_7_2_0_pre6/src/
		cmsenv
		cd $TEMPVAR; env
        