void sim(Int_t nev=300) {

  AliSimulation Sim;
  Sim.SetMakeSDigits("TRD TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");
  Sim.SetMakeDigitsFromHits("ITS TPC");

  Sim.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");

  // QA reference
  //Sim.SetQARefDefaultStorage("local://$ALICE_ROOT/QAref") ;

  // GRP
  Sim.SetSpecificStorage("GRP/GRP/Data",Form("local://%s",gSystem->pwd()));


  //vertex
  Sim.SetSpecificStorage("GRP/Calib/MeanVertexSPD","alien://folder=/alice/data/2009/OCDB");

  TStopwatch timer;
  timer.Start();

  Sim.Run(nev);

  timer.Stop();
  timer.Print();

}
