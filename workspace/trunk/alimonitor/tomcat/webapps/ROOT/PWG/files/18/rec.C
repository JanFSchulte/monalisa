void rec() {
  AliReconstruction reco;
  reco.SetUniformFieldTracking(kFALSE);
  reco.SetWriteESDfriend();
  reco.SetWriteAlignmentData();
  AliTPCRecoParam * tpcRecoParam = AliTPCRecoParam::GetLowFluxParam();
  AliTPCReconstructor::SetRecoParam(tpcRecoParam);
  AliTPCReconstructor::SetStreamLevel(1);
  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-10-Release/Ideal/?cacheFold=/tmp/CDBCache?operateDisconnected=kFALSE");
  reco.SetRunReconstruction("ITS TPC TRD TOF HMPID PHOS EMCAL MUON FMD PMD ZDC T0 VZERO");
  reco.SetRunQA(kFALSE);
  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}
