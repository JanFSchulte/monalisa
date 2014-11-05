void rec() {

  AliReconstruction reco;
  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-13-Release/Ideal/");
  reco.SetRunReconstruction("T0 VZERO");
  reco.SetRunVertexFinder(kFALSE);
  reco.SetRunTracking("");
  reco.SetOption("T0","pdc");
  reco.SetFillESD("T0 VZERO");
  reco.SetRunQA("VZERO:ESD");

  AliMagFMaps *field=new AliMagFMaps("Maps","Maps",2,1.,10.,AliMagFMaps::k5kG);
  Bool_t uniform=kFALSE;
  AliTracker::SetFieldMap(field,uniform);

  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}
