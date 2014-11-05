void rec() {
  AliReconstruction reco;
  reco.SetWriteESDfriend();
  reco.SetWriteAlignmentData();

  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");

  reco.SetRecoParam("ITS",AliITSRecoParam::GetHighFluxParam());
  reco.SetRecoParam("TPC",AliTPCRecoParam::GetHighFluxParam());
  reco.SetRecoParam("TRD",AliTRDrecoParam::GetHighFluxParam());

  Double_t cuts[]={33, 0.1, 0.1, 0.05, 0.99, 0.9, 100};
  AliV0vertexer::SetDefaultCuts(cuts);

  Double_t cts[]={33., 0.05, 0.008, 0.035, 0.1, 0.9985, 0.9,100};
  AliCascadeVertexer::SetDefaultCuts(cts);


  reco.SetSpecificStorage("ITS/Calib/SPDDead","alien://folder=/alice/data/2010/OCDB");


  // No write access to the OCDB => specific storage
  reco.SetSpecificStorage("GRP/GRP/Data",
                          Form("local://%s",gSystem->pwd()));

  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}