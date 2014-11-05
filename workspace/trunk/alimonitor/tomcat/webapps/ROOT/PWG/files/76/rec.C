void rec() {

	AliReconstruction reco;
	reco.SetWriteESDfriend();
	reco.SetWriteAlignmentData();
	reco.SetRecoParam("ITS",AliITSRecoParam::GetLowFluxParam());
	reco.SetRecoParam("TPC",AliTPCRecoParam::GetLowFluxParam());
	reco.SetRecoParam("TRD",AliTRDrecoParam::GetLowFluxParam());
	reco.SetRecoParam("PHOS",AliPHOSRecoParam::GetDefaultParameters());
	reco.SetRecoParam("MUON",AliMUONRecoParam::GetLowFluxParam());
	reco.SetRecoParam("EMCAL",AliEMCALRecParam::GetLowFluxParam());
 
	reco.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/?cacheFold=/tmp/CDBCache?operateDisconnected=kFALSE");

        reco.SetSpecificStorage("GRP/GRP/Data",
                          Form("local://%s",gSystem->pwd()));


	// add TRD standalone tracks
	reco.SetOption("TRD", "sl_tr_1");

 	reco.SetRunGlobalQA(kTRUE);

	TStopwatch timer;
	timer.Start();
	reco.Run();
	timer.Stop();
	timer.Print();
}
