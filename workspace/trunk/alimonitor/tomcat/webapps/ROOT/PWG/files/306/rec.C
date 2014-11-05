void rec()
{

  AliReconstruction reco;

  if (gSystem->Getenv("CONFIG_EMBEDDING")&&strcmp(gSystem->Getenv("CONFIG_EMBEDDING"), "kSignal")==0) {
    reco.SetRunReconstruction("ITS MUON");
  } else {
    reco.SetRunReconstruction("ITS MUON");
//    reco.SetRunReconstruction("ITS MUON VZERO ZDC");
  }

  reco.SetWriteESDfriend(kFALSE);
  reco.SetWriteAlignmentData(kFALSE);

  //  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetDefaultStorage("alien://Folder=/alice/data/2010/OCDB");
  // MUON Trigger
  reco.SetSpecificStorage("MUON/Calib/GlobalTriggerCrateConfig","alien://folder=/alice/simulation/2008/v4-15-Release/Ideal");
  reco.SetSpecificStorage("MUON/Calib/LocalTriggerBoardMasks","alien://folder=/alice/simulation/2008/v4-15-Release/Ideal");
  reco.SetSpecificStorage("MUON/Calib/RegionalTriggerConfig","alien://folder=/alice/simulation/2008/v4-15-Release/Ideal");
	
//	reco.SetSpecificStorage("GRP/GRP/Data",Form("local://%s",gSystem->pwd()));
	
  reco.SetRunQA(":");
	reco.SetRunGlobalQA(kFALSE);
  //  simulator.SetRunQA("MUON:ALL");

  reco.SetWriteESDfriend(kFALSE);
  reco.SetCleanESD(kFALSE);  
  reco.SetStopOnError(kFALSE);

  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();


// // Vertex from RAW OCDB

//   reco.SetSpecificStorage("GRP/Calib/MeanVertexTPC",   "alien://folder=/alice/data/2010/OCDB"); 
//   reco.SetSpecificStorage("GRP/Calib/MeanVertex",      "alien://folder=/alice/data/2010/OCDB");
//   reco.SetSpecificStorage("GRP/Calib/MeanVertexSPD",   "alien://folder=/alice/data/2010/OCDB");
//   reco.SetSpecificStorage("GRP/Calib/RecoParam",       "alien://folder=/alice/data/2010/OCDB"); 

// // Clock phase from RAW OCDB 

//   reco.SetSpecificStorage("GRP/Calib/LHCClockPhase",   "alien://folder=/alice/data/2010/OCDB");

// // ITS  

//   reco.SetSpecificStorage("ITS/Calib/RecoParam","alien://folder=/alice/data/2010/OCDB");
//   reco.SetSpecificStorage("ITS/Calib/SPDDead","alien://folder=/alice/data/2010/OCDB");
//   reco.SetSpecificStorage("TRIGGER/SPD/PITConditions","alien://folder=/alice/data/2010/OCDB");

// // ZDC

//   reco.SetSpecificStorage("ZDC/Calib/Pedestals","alien://folder=/alice/data/2010/OCDB");
// // EMCAL

//   reco.SetSpecificStorage("EMCAL/Calib/RecoParam", "alien://Folder=/alice/cern.ch/user/g/gconesab/ClusterizerNxN/OCDB"); 

// // VZERO

//   reco.SetSpecificStorage("VZERO/Calib/Data",          "alien://folder=/alice/data/2010/OCDB");
//   reco.SetSpecificStorage("VZERO/Trigger/Data",        "alien://folder=/alice/data/2010/OCDB");
//   reco.SetSpecificStorage("VZERO/Calib/RecoParam",     "alien://folder=/alice/data/2010/OCDB");
//   reco.SetSpecificStorage("VZERO/Calib/TimeSlewing",   "alien://folder=/alice/data/2010/OCDB");
//   reco.SetSpecificStorage("VZERO/Calib/TimeDelays",    "alien://folder=/alice/data/2010/OCDB");

//   // MUON
//   reco.SetSpecificStorage("MUON/Calib/TriggerLut",     "alien://folder=/alice/data/2010/OCDB");
  // No write access to the OCDB => specific storage

  //   reco.SetSpecificStorage("GRP/GRP/Data",
  //                           Form("local://%s",gSystem->pwd()));


}


