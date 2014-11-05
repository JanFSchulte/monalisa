void rec() {  
  AliReconstruction reco;
  reco.SetRunReconstruction("ITS TPC TRD TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");

  reco.SetWriteESDfriend();
  reco.SetWriteAlignmentData();

  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");

  reco.SetRecoParam("TPC",AliTPCRecoParam::GetHighFluxParam());
  reco.SetRecoParam("TRD",AliTRDrecoParam::GetHighFluxParam());

  Double_t cuts[]={33, 0.1, 0.1, 0.05, 0.99, 0.9, 100};
  AliV0vertexer::SetDefaultCuts(cuts);

  Double_t cts[]={33., 0.05, 0.008, 0.035, 0.1, 0.9985, 0.9,100};
  AliCascadeVertexer::SetDefaultCuts(cts);

//
// Vertex from RAW OCDB
  reco.SetSpecificStorage("GRP/Calib/MeanVertexTPC",   "alien://folder=/alice/data/2010/OCDB"); 
  reco.SetSpecificStorage("GRP/Calib/MeanVertex",      "alien://folder=/alice/data/2010/OCDB");
  reco.SetSpecificStorage("GRP/Calib/MeanVertexSPD",   "alien://folder=/alice/data/2010/OCDB");
  reco.SetSpecificStorage("GRP/Calib/RecoParam",       "alien://folder=/alice/data/2010/OCDB"); 

// Clock phase from RAW OCDB 
  reco.SetSpecificStorage("GRP/Calib/LHCClockPhase",   "alien://folder=/alice/data/2010/OCDB");
  
// ITS
  reco.SetSpecificStorage("ITS/Calib/RecoParam","alien://folder=/alice/cern.ch/user/f/frprino/recoparam/"); 
  reco.SetSpecificStorage("ITS/Calib/SPDDead","alien://folder=/alice/data/2010/OCDB");
  reco.SetSpecificStorage("TRIGGER/SPD/PITConditions","alien://folder=/alice/data/2010/OCDB");
  reco.SetSpecificStorage("ITS/Calib/SPDNoise","alien://folder=/alice/data/2010/OCDB"); 
  reco.SetSpecificStorage("ITS/Calib/CalibSDD","alien://Folder=/alice/data/2010/OCDB");

// ZDC
  reco.SetSpecificStorage("ZDC/Calib/Pedestals","alien://folder=/alice/data/2010/OCDB");
// EMCAL
  reco.SetSpecificStorage("EMCAL/Calib/RecoParam", "alien://Folder=/alice/cern.ch/user/g/gconesab/ClusterizerNxN/OCDB"); 

// VZERO
  reco.SetSpecificStorage("VZERO/Calib/Data",          "alien://folder=/alice/data/2010/OCDB");
  reco.SetSpecificStorage("VZERO/Trigger/Data",        "alien://folder=/alice/data/2010/OCDB");
  reco.SetSpecificStorage("VZERO/Calib/RecoParam",     "alien://folder=/alice/data/2010/OCDB");
  reco.SetSpecificStorage("VZERO/Calib/TimeSlewing",   "alien://folder=/alice/data/2010/OCDB");
  reco.SetSpecificStorage("VZERO/Calib/TimeDelays",    "alien://folder=/alice/data/2010/OCDB");

  // No write access to the OCDB => specific storage
  reco.SetSpecificStorage("GRP/GRP/Data",
                          Form("local://%s",gSystem->pwd()));

  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}

