void sim(Int_t nev=10) {
  AliSimulation simulator;
  simulator.SetWriteRawData("ALL","raw.root",kTRUE);
  simulator.SetMakeSDigits("TRD TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");
  simulator.SetMakeDigits("ITS TPC TRD TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");
  simulator.SetMakeDigitsFromHits("ITS TPC");
//
// Ideal OCDB

  simulator.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");

// Read GRP Data from RAW
  simulator.SetSpecificStorage("GRP/GRP/Data",                 "alien://Folder=/alice/data/2010/OCDB");
//
// Mean verrtex from RAW OCDB 
  simulator.SetSpecificStorage("GRP/Calib/MeanVertexSPD",       "alien://folder=/alice/data/2010/OCDB"); 
  simulator.SetSpecificStorage("GRP/Calib/MeanVertex",          "alien://folder=/alice/data/2010/OCDB");
// Clock phase from RAW OCDB 
  simulator.SetSpecificStorage("GRP/Calib/LHCClockPhase",       "alien://folder=/alice/data/2010/OCDB");
// ZDC
  simulator.SetSpecificStorage("ZDC/Calib/Pedestals","alien://folder=/alice/data/2010/OCDB");
// VZERO
  simulator.SetSpecificStorage("VZERO/Calib/Data",             "alien://Folder=/alice/data/2010/OCDB");
  simulator.SetSpecificStorage("VZERO/Trigger/Data",           "alien://folder=/alice/data/2010/OCDB");
  simulator.SetSpecificStorage("VZERO/Calib/RecoParam",        "alien://folder=/alice/data/2010/OCDB");
  simulator.SetSpecificStorage("VZERO/Calib/TimeSlewing",      "alien://folder=/alice/data/2010/OCDB");
  simulator.SetSpecificStorage("VZERO/Calib/TimeDelays",       "alien://folder=/alice/data/2010/OCDB");

// MUON 
// Pedestals  
  simulator.SetSpecificStorage("MUON/Calib/Pedestals","alien://folder=/alice/data/2010/OCDB");
// MappingData
  simulator.SetSpecificStorage("MUON/Calib/MappingData","alien://folder=/alice/data/2010/OCDB");
// Trigger LuT 
  simulator.SetSpecificStorage("MUON/Calib/TriggerLut","alien://folder=/alice/data/2010/OCDB");
// Trigger efficiency 
  simulator.SetSpecificStorage("MUON/Calib/TriggerEfficiency", "alien://folder=/alice/simulation/2008/v4-15-Release/Full");


//
// Vertex and Mag.field from OCDB
  simulator.UseVertexFromCDB();
  simulator.UseMagFieldFromGRP();

// 7% more material budget

  simulator.AliModule::SetDensityFactor(1.07);

 
//
// The rest

  TStopwatch timer;
  timer.Start();
  simulator.Run(nev);
  timer.Stop();
  timer.Print();
}
