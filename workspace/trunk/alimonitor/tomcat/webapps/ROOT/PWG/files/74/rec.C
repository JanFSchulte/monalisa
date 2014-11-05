void rec() {
	//  AliLog::SetGlobalDebugLevel(10);
	AliCDBManager * man = AliCDBManager::Instance();
	man->SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");    
	
	AliReconstruction reco;
	reco.SetWriteESDfriend();
	reco.SetWriteAlignmentData();

	reco.SetRecoParam("ITS",AliITSRecoParam::GetHighFluxParam());
	reco.SetRecoParam("TPC",AliTPCRecoParam::GetHighFluxParam());
	//AliTPCReconstructor::SetStreamLevel(1); //??
	reco.SetRecoParam("TRD",AliTRDrecoParam::GetHighFluxParam());
	reco.SetRecoParam("PHOS",AliPHOSRecoParam::GetDefaultParameters());
	reco.SetRecoParam("MUON",AliMUONRecoParam::GetHighFluxParam());
	reco.SetRecoParam("EMCAL",AliEMCALRecParam::GetHighFluxParam());

	reco.SetRunReconstruction("ITS TPC TRD TOF HMPID PHOS EMCAL T0 VZERO FMD PMD ZDC HLT MUON");	
	reco.SetRunQA(":") ;
	reco.SetRunGlobalQA(kFALSE) ; 

        //Vertex
        //AliGRPRecoParam *grpRecoParam = AliGRPRecoParam::GetLowFluxParam();
        //grpRecoParam->SetVertexerTracksConstraintITS(kFALSE);
        //grpRecoParam->SetVertexerTracksConstraintTPC(kFALSE);
        //reco.SetRecoParam("GRP",grpRecoParam);
	
	// **** The field map settings must be the same as in Config.C !
	//AliMagWrapCheb * field = new AliMagWrapCheb("Maps","Maps", 2, 1., 10., AliMagWrapCheb::k5kG);
	AliMagWrapCheb * field = new AliMagWrapCheb("Maps","Maps", 2, 1., 10., AliMagWrapCheb::k5kG,kTRUE,"$(ALICE_ROOT)/data/maps/mfchebKGI_sym.root");
	AliTracker::SetFieldMap(field,kTRUE);
	reco.SetUniformFieldTracking(kFALSE);	
	
	TStopwatch timer;
	timer.Start();
	reco.Run();
	timer.Stop();
	timer.Print();
}
