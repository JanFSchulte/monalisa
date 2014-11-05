void rec() {
  /* AliLog::SetGlobalLogLevel(AliLog::kInfo);
  AliLog::SetClassDebugLevel("AliTOFtracker",2);
  AliLog::SetClassDebugLevel("AliTOFtrackerV1",2);
  AliLog::SetClassDebugLevel("AliTOFGeometry",2);*/

  AliReconstruction reco;


  reco.SetWriteESDfriend();
  reco.SetWriteAlignmentData();

  // reco.SetRecoParam("ITS",AliITSRecoParam::GetHighFluxParam());   
   AliITSRecoParam * itsRecoParam = AliITSRecoParam::GetHighFluxParam(); //Pb-Pb
 // trackleter options ...
  itsRecoParam->SetTrackleterOnlyOneTrackletPerC2(kFALSE);

  itsRecoParam->SetTrackleterPhiWindow(0.015); //rad
  itsRecoParam->SetTrackleterZetaWindow(0.03); //cm

  reco.SetRecoParam("ITS",itsRecoParam);

  reco.SetRecoParam("TPC",AliTPCRecoParam::GetHighFluxParam());
  reco.SetRecoParam("TRD",AliTRDrecoParam::GetHighFluxParam());
  reco.SetRecoParam("TOF",AliTOFRecoParam::GetPbPbparam());
  reco.SetRecoParam("PHOS",AliPHOSRecoParam::GetDefaultParameters());
  reco.SetRecoParam("MUON",AliMUONRecoParam::GetHighFluxParam());

  reco.SetRunVertexFinderTracks(kFALSE);

  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal");
  reco.SetSpecificStorage("GRP/GRP/Data",
			  Form("local://%s",gSystem->pwd()));

  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}
