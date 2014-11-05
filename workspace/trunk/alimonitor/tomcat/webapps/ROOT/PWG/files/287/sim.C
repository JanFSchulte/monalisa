void sim(Int_t nev=400) {
// void sim(Int_t nev=10) {
  AliSimulation simulator;

  simulator.SetWriteRawData("ALL","raw.root",kTRUE);
  simulator.SetMakeSDigits("TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");
  simulator.SetMakeDigits("ITS TPC TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");
  simulator.SetMakeDigitsFromHits("ITS TPC");
//
//
// RAW OCDB
  simulator.SetDefaultStorage("alien://Folderr=/alice/data/2011/OCDB");
//
// Specific storages = 26 

//
// ITS  (1 Total)
//     Alignment from Ideal OCDB 

  simulator.SetSpecificStorage("ITS/Align/Data",  "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal");

//
// MUON  (1 Total)
//      MCH

  simulator.SetSpecificStorage("MUON/Align/Data",  "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");

//
// TPC (24 total) 

simulator.SetSpecificStorage("TPC/Calib/PadGainFactor",   "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/TimeGain",       "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/GainFactorDedx", "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/PadTime0",       "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/Distortion",     "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/PadNoise",       "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/PadNoise",       "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/Pedestals",      "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/Temperature",    "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/Parameters",     "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/ClusterParam",   "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/AltroConfig",    "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/Pulser",         "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/Pulser",         "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/CE",             "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/Mapping",        "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/Correction",     "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Align/Data",           "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/Goofie",         "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/TimeDrift",      "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/Raw",            "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/QA",             "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");
simulator.SetSpecificStorage("TPC/Calib/HighVoltage",    "alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/");

//
// Vertex and Mag.field from OCDB

  simulator.UseVertexFromCDB();
  simulator.UseMagFieldFromGRP();

//
// The rest
//
  simulator.Run(nev);
}
