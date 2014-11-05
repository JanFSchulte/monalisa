void rec() {

  AliCDBManager::Instance()->SetRun(0);

  AliMagFMaps* field = new AliMagFMaps("Maps","Maps", 2, 1., 10., AliMagFMaps::k5kG);
  AliTracker::SetFieldMap(field,kTRUE);

  AliReconstruction MuonRec;

  MuonRec.SetInput("raw.root");
  
  MuonRec.SetRunLocalReconstruction("MUON ITS VZERO FMD");
  MuonRec.SetRunTracking("MUON ITS VZERO FMD");
  
  MuonRec.SetRunVertexFinder(kTRUE);
  
  MuonRec.SetFillESD("MUON VZERO FMD");
  MuonRec.SetWriteAOD();
  
      MuonRec.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-10-Release/Ideal/");
    MuonRec.SetSpecificStorage("MUON/Calib/TriggerLut","alien://Folder=/alice/cern.ch/user/b/bogdan/prod2008/cdb/");


  MuonRec.SetNumberOfEventsPerFile(-1); // all events in one single file

  TStopwatch timer;
  timer.Start();
  MuonRec.Run();
  timer.Stop();
  timer.Print();
  
}
