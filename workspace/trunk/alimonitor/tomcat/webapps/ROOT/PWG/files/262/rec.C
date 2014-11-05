void rec() {  
  //
  AliReconstruction reco;
  //  reco.SetRunReconstruction("ITS TPC TRD TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");
  reco.SetRunReconstruction("ITS TPC TOF VZERO");

  //reco.SetRunLocalReconstruction("");

  reco.SetWriteESDfriend();
  reco.SetWriteAlignmentData();
  reco.SetRunQA(":");
  reco.SetRunGlobalQA(kFALSE);

  const char* rawPath = "alien://folder=/alice/data/2010/OCDB";
  //const char* rawPath = "local:///data/OCDBs/2010/OCDB";

  const char* mcPath  = "alien://Folder=/alice/simulation/2008/v4-15-Release/Residual";  
  //const char* mcPath  = "local:///data/OCDBs/2008s/v4-15-Release/Residual";
  //
  reco.SetDefaultStorage(mcPath); 
  //
  // Vertex from RAW OCDB
  reco.SetSpecificStorage("GRP/Calib/MeanVertexTPC",   rawPath); 
  reco.SetSpecificStorage("GRP/Calib/MeanVertex",      rawPath);
  reco.SetSpecificStorage("GRP/Calib/MeanVertexSPD",   rawPath);
  reco.SetSpecificStorage("GRP/Calib/RecoParam",       rawPath); 
  //
  // Clock phase from RAW OCDB 
  reco.SetSpecificStorage("GRP/Calib/LHCClockPhase",   rawPath);
  //
  // ITS
  reco.SetSpecificStorage("ITS/Calib/RecoParam",       rawPath); 
  reco.SetSpecificStorage("ITS/Calib/SPDDead",         rawPath);
  reco.SetSpecificStorage("TRIGGER/SPD/PITConditions", rawPath);
  // SDD
  reco.SetSpecificStorage("ITS/Calib/CalibSDD",        rawPath); 
  // SSD
  reco.SetSpecificStorage("ITS/Calib/NoiseSSD",        rawPath);
  reco.SetSpecificStorage("ITS/Calib/BadChannelsSSD",  rawPath); 

  // TPC
  // TPC from RAW OCDB
  reco.SetSpecificStorage("TPC/Calib/PadGainFactor",   rawPath);
  //
  // TRD from RAW OCDB
  reco.SetSpecificStorage("TRD/Calib/ChamberStatus",   rawPath);
  reco.SetSpecificStorage("TRD/Calib/PadStatus",       rawPath);
  //
  // TOF from RAW OCDB
  reco.SetSpecificStorage("TOF/Calib/Status",          rawPath);
  //
  // EMCAL from RAW OCDB
  reco.SetSpecificStorage("EMCAL/Calib/Data",          rawPath);
  reco.SetSpecificStorage("EMCAL/Calib/Pedestals",     rawPath);
  reco.SetSpecificStorage("EMCAL/Calib/RecoParam",     rawPath);

  //
  // PHOS from RAW OCDB
  reco.SetSpecificStorage("PHOS/Calib/EmcBadChannels", rawPath);
  reco.SetSpecificStorage("PHOS/Calib/RecoParam",      rawPath);
  reco.SetSpecificStorage("PHOS/Calib/Mapping",        rawPath);
  //
  // VZERO
  reco.SetSpecificStorage("VZERO/Calib/Data",          rawPath);
  reco.SetSpecificStorage("VZERO/Trigger/Data",        rawPath);
  reco.SetSpecificStorage("VZERO/Calib/RecoParam",     rawPath);
  reco.SetSpecificStorage("VZERO/Calib/TimeSlewing",   rawPath);
  reco.SetSpecificStorage("VZERO/Calib/TimeDelays",    rawPath);
  //
  // FMD from RAW OCDB
  reco.SetSpecificStorage("FMD/Calib/Pedestal",        rawPath);
  reco.SetSpecificStorage("FMD/Calib/PulseGain",       rawPath);
  reco.SetSpecificStorage("FMD/Calib/Dead",            rawPath);
  reco.SetSpecificStorage("FMD/Calib/AltroMap",        rawPath);
  //
  // MUON
  // Config
  reco.SetSpecificStorage("MUON/Calib/Config",         rawPath);
  // MappingData
  reco.SetSpecificStorage("MUON/Calib/MappingData",    rawPath);
  // MappingRunData
  reco.SetSpecificStorage("MUON/Calib/MappingRunData", rawPath);
  // Neighbours
  reco.SetSpecificStorage("MUON/Calib/Neighbours",     rawPath);
  // OccupancyMap
  reco.SetSpecificStorage("MUON/Calib/OccupancyMap",   rawPath);
  // Pedestals
  reco.SetSpecificStorage("MUON/Calib/Pedestals",      rawPath);
  // HV
  reco.SetSpecificStorage("MUON/Calib/HV",             rawPath);
  // RecParam
  reco.SetSpecificStorage("MUON/Calib/RecoParam",      rawPath);
  // RejectList
  reco.SetSpecificStorage("MUON/Calib/RejectList",     rawPath);
  // Alignment (2nd alignment in Residual, not needed Residual is the default)
  reco.SetSpecificStorage("MUON/Align/Data",           mcPath);
  // Trigger LuT 
  reco.SetSpecificStorage("MUON/Calib/TriggerLut",     rawPath);
  // Trigger DCS (for QA)
  reco.SetSpecificStorage("MUON/Calib/TriggerDCS",     rawPath);

  //
  // ZDC
  reco.SetSpecificStorage("ZDC/Calib/Pedestals",       rawPath);
  // No write access to the OCDB => specific storage

  // customize ITS recoparam to overcome MC trigger problems
  { 
    AliITSRecoParam * itsRecoParam = AliITSRecoParam::GetHighFluxParam();

    itsRecoParam->SetSkipSubdetsNotInTriggerCluster(kFALSE); // RS: this is important

    itsRecoParam->SetClusterErrorsParam(2);
    
    // find independently ITS SA tracks for nContrSPD<50
    itsRecoParam->SetSAUseAllClusters();
    itsRecoParam->SetMaxSPDcontrForSAToUseAllClusters(50);

    itsRecoParam->SetImproveWithVertex(kTRUE);
    // Misalignment syst errors decided at ITS meeting 25.03.2010
    // additional error due to misal (B off)
    itsRecoParam->SetClusterMisalErrorY(0.0010,0.0010,0.0300,0.0300,0.0020,0.0020); // [cm]
    itsRecoParam->SetClusterMisalErrorZ(0.0100,0.0100,0.0100,0.0100,0.0500,0.0500); // [cm]
    // additional error due to misal (B on)
    itsRecoParam->SetClusterMisalErrorYBOn(0.0010,0.0030,0.0500,0.0500,0.0020,0.0020); // [cm]
    itsRecoParam->SetClusterMisalErrorZBOn(0.0050,0.0050,0.0050,0.0050,0.1000,0.1000); // [cm]
    //----

    //Vertexer Z
    itsRecoParam->SetVertexerZ();


    // tracklets
    itsRecoParam->SetTrackleterPhiWindowL2(0.07);
    itsRecoParam->SetTrackleterZetaWindowL2(0.4);
    itsRecoParam->SetTrackleterPhiWindowL1(0.10);
    itsRecoParam->SetTrackleterZetaWindowL1(0.6);
    //
    itsRecoParam->SetTrackleterPhiWindow(0.06);
    itsRecoParam->SetTrackleterThetaWindow(0.025);
    itsRecoParam->SetTrackleterScaleDThetaBySin2T(kTRUE);
    //
    // Removal of tracklets reconstructed in the SPD overlaps 
    itsRecoParam->SetTrackleterRemoveClustersFromOverlaps(kTRUE);

    // SDD configuration 
    itsRecoParam->SetUseSDDCorrectionMaps(kFALSE); 
    itsRecoParam->SetUseSDDClusterSizeSelection(kTRUE);
    itsRecoParam->SetMinClusterChargeSDD(30.);
    itsRecoParam->SetUseUnfoldingInClusterFinderSDD(kFALSE);

    itsRecoParam->SetEventSpecie(AliRecoParam::kHighMult);
    itsRecoParam->SetTitle("HighMult");
    reco.SetRecoParam("ITS",itsRecoParam);
  }
  
  //
  reco.SetSpecificStorage("GRP/GRP/Data", Form("local://%s",gSystem->pwd()));


  TStopwatch timer;
  timer.Start();


  reco.Run();
  timer.Stop();
  timer.Print();
}
