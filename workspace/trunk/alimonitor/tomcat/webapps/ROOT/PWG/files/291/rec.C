void rec() {  
  AliReconstruction reco;
  reco.SetRunReconstruction("ITS TPC TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");

  reco.SetWriteESDfriend();
  reco.SetWriteAlignmentData();

  reco.SetDefaultStorage("alien://Folder=/alice/data/2010/OCDB");

// Total number of specific storages - 28
//
// ITS (2 objects)

  reco.SetSpecificStorage("ITS/Align/Data",     "alien://folder=/alice/simulation/2008/v4-15-Release/Residual");
  reco.SetSpecificStorage("ITS/Calib/SPDNoisy", "alien://folder=/alice/simulation/2008/v4-15-Release/Residual");

//
// MUON (1 objects)
//      MCH

  reco.SetSpecificStorage("MUON/Align/Data",    "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");

//
// TPC (25 objects)

  reco.SetSpecificStorage("TPC/Align/Data", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/GainFactorDedx", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/PadTime0", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/ClusterParam", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/Pedestals", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/Parameters", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/ExB", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/Mapping", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/PadNoise", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/PadGainFactor", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/Temperature", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/RecoParam", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/TimeGain", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/AltroConfig", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/CE", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/Pulser", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/Distortion", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/Ref", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/Raw", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/QA", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/TimeDrift", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/Goofie", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/HighVoltage", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/LaserTracks", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  reco.SetSpecificStorage("TPC/Calib/Correction", "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");

  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}
