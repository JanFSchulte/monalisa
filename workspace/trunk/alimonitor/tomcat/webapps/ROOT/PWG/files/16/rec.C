void rec() {
  AliLog::SetGlobalLogLevel(AliLog::kError);
  AliReconstruction reco;
  reco.SetUniformFieldTracking(kFALSE);
  reco.SetWriteESDfriend();
  reco.SetWriteAlignmentData();
  AliTPCRecoParam * tpcRecoParam = AliTPCRecoParam::GetLowFluxParam();
  AliTPCReconstructor::SetRecoParam(tpcRecoParam);
  AliTPCReconstructor::SetStreamLevel(1);
  reco.SetDefaultStorage("alien://Folder=/alice/simulation/2007/PDC07_v4-09-Rev-00/Ideal/CDB/?cacheFold=/tmp/CDBCache");
  reco.SetRunReconstruction("ITS TPC TRD TOF HMPID PHOS EMCAL MUON FMD PMD ZDC T0 VZERO");
 
 Double_t v0sels[]={33,  // max allowed chi2
				0.05, // min allowed impact parameter for the 1st daughter 
				0.05, // min allowed impact parameter for the 2nd daughter
				0.5,  // max allowed DCA between the daughter tracks
				0.99, // max allowed cosine of V0's pointing angle
				0.2,  // min radius of the fiducial volume
				100   // max radius of the fiducial volume
  };
  AliV0vertexer::SetDefaultCuts(v0sels);

  Double_t xisels[]={33.,  // max allowed chi2
                 0.05,  // min allowed V0 impact parameter 
                 0.008,  // "window" around the Lambda mass 
                 0.035, // min allowed bachelor's impact parameter 
                 0.1,  // max allowed DCA between the V0 and the bachelor
                 0.9985,// max allowed cosine of the cascade pointing angle
                 0.9,   // min radius of the fiducial volume
                 100    // max radius of the fiducial volume
  };
  AliCascadeVertexer::SetDefaultCuts(xisels);
 
 
  TStopwatch timer;
  timer.Start();
  reco.Run();
  timer.Stop();
  timer.Print();
}
