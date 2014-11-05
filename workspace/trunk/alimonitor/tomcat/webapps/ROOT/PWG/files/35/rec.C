void rec() {

  AliReconstruction reco;
  reco.SetUniformFieldTracking(kFALSE);
  reco.SetWriteESDfriend();
  reco.SetWriteAlignmentData();

  AliTPCRecoParam * tpcRecoParam = AliTPCRecoParam::GetHighFluxParam();
  AliTPCReconstructor::SetRecoParam(tpcRecoParam);
  AliTPCReconstructor::SetStreamLevel(0);

  reco.SetRunReconstruction("ITS TPC TRD TOF HMPID PHOS EMCAL MUON VZERO T0 FMD PMD ZDC");
  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-12-Release/Ideal/");
  reco.SetRunQA(kFALSE);
  reco.SetRunGlobalQA(kFALSE);

  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}
