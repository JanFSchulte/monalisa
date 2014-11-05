void rec() {
  AliReconstruction reco;
  reco.SetUniformFieldTracking(kFALSE);
  reco.SetWriteESDfriend(kFALSE);
  reco.SetWriteAlignmentData(kFALSE);
  AliTPCRecoParam * tpcRecoParam = AliTPCRecoParam::GetHighFluxParam();
  AliTPCReconstructor::SetRecoParam(tpcRecoParam);
  AliTPCReconstructor::SetStreamLevel(0);
  reco.SetRunReconstruction("ITS TPC TRD TOF PHOS HMPID EMCAL MUON FMD ZDC T0 VZERO");

  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2007/PDC07_1/Ideal/CDB/");

  AliCDBManager::Instance()->SetSpecificStorage("EMCAL/*","local://DBpp");

  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}
