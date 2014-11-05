void sim(Int_t nev=1000) {

  AliSimulation MuonSim;
  MuonSim.SetMakeTrigger("MUON");
  MuonSim.SetMakeSDigits("MUON ITS");
  MuonSim.SetMakeDigits("MUON ITS VZERO");
  MuonSim.SetWriteRawData("MUON ITS VZERO","raw.root",kTRUE);
  MuonSim.SetRunHLT("");
  MuonSim.SetRunQA("MUON:ALL");

  MuonSim.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");

  // QA reference
  MuonSim.SetQARefDefaultStorage("local://$ALICE_ROOT/QAref") ;

  // GRP
  MuonSim.SetSpecificStorage("GRP/GRP/Data",Form("local://%s",gSystem->pwd()));

// CTP
  MuonSim.SetSpecificStorage("GRP/CTP/Config","alien://folder=/alice/cern.ch/user/b/bogdan/prod2009/cdb");

  // trigger (LuT)
  MuonSim.SetSpecificStorage("MUON/Calib/TriggerLut","alien://folder=/alice/data/2009/OCDB");

  //vertex
  MuonSim.SetSpecificStorage("GRP/Calib/MeanVertexSPD","alien://folder=/alice/data/2009/OCDB");

  TStopwatch timer;
  timer.Start();

  MuonSim.Run(nev);

  timer.Stop();
  timer.Print();

}
