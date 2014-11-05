void rec() {

  AliReconstruction MuonRec;

  MuonRec.SetRunLocalReconstruction("MUON ITS VZERO");
  MuonRec.SetRunTracking("MUON ITS VZERO");
  MuonRec.SetRunVertexFinder(kTRUE);
  MuonRec.SetFillESD("MUON VZERO ITS");
  MuonRec.SetRunQA("MUON:ALL");
  
  MuonRec.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Residual");

  // QA reference
  MuonRec.SetQARefDefaultStorage("local://$ALICE_ROOT/QAref") ;
  
  //GRP
  MuonRec.SetSpecificStorage("GRP/GRP/Data",Form("local://%s",gSystem->pwd()));

  // CTP
  MuonRec.SetSpecificStorage("GRP/CTP/Config","alien://folder=/alice/cern.ch/user/b/bogdan/prod2009/cdb");

 // MUON Alignment
  MuonRec.SetSpecificStorage("MUON/Align/Data","alien://folder=/alice/simulation/2008/v4-15-Release/Full");

 // MUON Tracking (RecoParam)
  MuonRec.SetSpecificStorage("MUON/Calib/RecoParam","alien://folder=/alice/simulation/2008/v4-15-Release/Full");

// MUON Tracking (RejectList)
  MuonRec.SetSpecificStorage("MUON/Calib/RejectList","alien://folder=/alice/simulation/2008/v4-15-Release/Full");

 // VertexSPD
  MuonRec.SetSpecificStorage("GRP/Calib/MeanVertexSPD","alien://folder=/alice/data/2009/OCDB");
  MuonRec.SetSpecificStorage("GRP/Calib/MeanVertex","alien://folder=/alice/data/2009/OCDB");  

 // SPD
  MuonRec.SetSpecificStorage("ITS/Calib/SPDDead","alien://Folder=/alice/data/2009/OCDB");
  MuonRec.SetSpecificStorage("TRIGGER/SPD/PITConditions","alien://folder=/alice/data/2009/OCDB");	
	
  MuonRec.SetNumberOfEventsPerFile(1000);

  TStopwatch timer;
  timer.Start();
  MuonRec.Run();
  timer.Stop();
  timer.Print();
  
}
