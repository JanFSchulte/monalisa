void rec() {
  AliReconstruction reco;

  reco.SetWriteESDfriend();
  reco.SetWriteAlignmentData();

//  reco.SetRunReconstruction("ITS TPC TRD TOF");

  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Residual/");
  //  reco.SetDefaultStorage("local://$ALICE_ROOT/OCDB");
  reco.SetSpecificStorage("GRP/GRP/Data",
			  Form("local://%s",gSystem->pwd()));

//   reco.SetEventRange(0,30000);
   
    reco.SetRunQA(":");
  
//  reco.SetQARefDefaultStorage("local://$ALICE_ROOT/QAref") ;
  
//   for (Int_t det = 0 ; det < AliQA::kNDET ; det++) {
//     reco.SetQACycles(det, 999) ;
//     reco.SetQAWriteExpert(det) ; 
 //  }
  
  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}
