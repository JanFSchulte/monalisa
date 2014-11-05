void rec() {
	//  AliLog::SetGlobalDebugLevel(10);
	AliCDBManager * man = AliCDBManager::Instance();
	man->SetDefaultStorage("alien://Folder=/alice/simulation/2007/PDC07_v4-09-Rev-00/Ideal/CDB/");
	man->SetSpecificStorage("EMCAL/*","local://DB");
	
	AliReconstruction reco;
	AliMagFMaps* field = new AliMagFMaps("Maps","Maps", 2, 1., 10., AliMagFMaps::k5kG);
	AliTracker::SetFieldMap(field,kTRUE);
	reco.SetUniformFieldTracking(kFALSE);
	reco.SetWriteESDfriend();
	reco.SetWriteAlignmentData();
  
	AliTPCRecoParam * tpcRecoParam = AliTPCRecoParam::GetLowFluxParam();
	AliTPCReconstructor::SetRecoParam(tpcRecoParam);
	AliTPCReconstructor::SetStreamLevel(0);
	reco.SetRunReconstruction("ITS TPC TRD TOF HMPID PHOS EMCAL MUON T0 VZERO FMD PMD ZDC");
	//reco.SetInput("raw.root") ;
	//AliPHOSRecoParam* recEmc = new AliPHOSRecoParamEmc();
//	recEmc->SetSubtractPedestals(kFALSE);
//	AliPHOSReconstructor::SetRecoParamEmc(recEmc);  
	reco.SetRunQA(kFALSE) ; 

	TStopwatch timer;
	timer.Start();
	reco.Run();
	timer.Stop();
	timer.Print();
}
