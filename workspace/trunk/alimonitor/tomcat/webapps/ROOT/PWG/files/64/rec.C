void rec() {

  AliReconstruction reco;
  reco.SetWriteESDfriend();
  reco.SetWriteAlignmentData();

  reco.SetRecoParam("ITS",AliITSRecoParam::GetHighFluxParam());
  reco.SetRecoParam("TPC",AliTPCRecoParam::GetHighFluxParam());
  reco.SetRecoParam("TRD",AliTRDrecoParam::GetHighFluxParam());
  reco.SetRecoParam("PHOS",AliPHOSRecoParam::GetDefaultParameters());
  reco.SetRecoParam("EMCAL",AliEMCALRecParam::GetDefaultParameters());
  reco.SetRecoParam("MUON",AliMUONRecoParam::GetHighFluxParam());

  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/?cacheFold=/tmp/CDBCache?operateDisconnected=kFALSE");
  reco.SetSpecificStorage("GRP/GRP/Data",
			  Form("local://%s",gSystem->pwd()));

  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}
