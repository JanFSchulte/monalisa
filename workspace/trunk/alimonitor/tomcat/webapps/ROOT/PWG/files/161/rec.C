void rec() {

  AliReconstruction reco;
// switch off cleanESD
  reco.SetCleanESD(kFALSE);


  reco.SetWriteESDfriend();
  reco.SetWriteAlignmentData();
  reco.SetRunQA("ALL:ALL");

  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
   reco.SetSpecificStorage("GRP/GRP/Data",
 	                        Form("local://%s",gSystem->pwd()));


//
  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}
