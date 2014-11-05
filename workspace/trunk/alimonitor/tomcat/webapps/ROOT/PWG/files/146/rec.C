void rec() {
  AliReconstruction reco;
  reco.SetRunVertexFinder(kFALSE) ; 

  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("PHOS/Calib/EmcBadChannels","alien://Folder=/alice/data/2009/OCDB");
  reco.SetSpecificStorage("EMCAL/Calib/Pedestals","alien://Folder=/alice/data/2009/OCDB");
  reco.SetSpecificStorage("GRP/GRP/Data","alien://Folder=/alice/cern.ch/user/k/kharlov/production/pi0_2gamma");

  TString name="PHOS";
  reco.SetRunReconstruction(name);
  reco.SetRunTracking(name) ;
  reco.SetFillESD(name) ;
  reco.SetRunQA("PHOS:ALL");
  reco.SetRunGlobalQA(kFALSE);
  reco.SetRunHLTTracking(kFALSE);

  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}
