void rec() {

  AliReconstruction Rec;
 
  Rec.SetRunQA("ALL:ALL");
  Rec.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Residual");

  // QA reference
  Rec.SetQARefDefaultStorage("local://$ALICE_ROOT/QAref") ;

  //GRP
  Rec.SetSpecificStorage("GRP/GRP/Data",Form("local://%s",gSystem->pwd()));

 // Vertex
  Rec.SetSpecificStorage("GRP/Calib/MeanVertexSPD",     "alien://folder=/alice/data/2009/OCDB");
  Rec.SetSpecificStorage("GRP/Calib/MeanVertex",        "alien://folder=/alice/data/2009/OCDB");
  Rec.SetSpecificStorage("GRP/Calib/MeanVertexTPC",     "alien://folder=/alice/data/2009/OCDB");

 // SPD
  Rec.SetSpecificStorage("ITS/Calib/SPDDead","alien://Folder=/alice/data/2009/OCDB");
  Rec.SetSpecificStorage("TRIGGER/SPD/PITConditions","alien://folder=/alice/data/2009/OCDB");
//
// Reco Param
  Rec.SetSpecificStorage("ITS/Calib/RecoParam","alien://folder=/alice/data/2009/OCDB");
  Rec.SetSpecificStorage("GRP/Calib/RecoParam","alien://folder=/alice/data/2009/OCDB");
//
// TPC
//
  Rec.SetSpecificStorage("TPC/Calib/PadGainFactor",     "alien://folder=/alice/data/2009/OCDB");
//
// PMD: this object is missing in the MC OCDB
//
  Rec.SetSpecificStorage("PMD/Calib/NoiseCut",     "alien://folder=/alice/data/2009/OCDB");

  TStopwatch timer;
  timer.Start();
  Rec.Run();
  timer.Stop();
  timer.Print();

}
