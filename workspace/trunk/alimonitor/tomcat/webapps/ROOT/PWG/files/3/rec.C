{
AliReconstruction rec;
char *names="ITS TPC TRD TOF";
rec.SetRunLocalReconstruction("");
rec.SetRunTracking(names);
rec.SetFillESD(names);
//rec.SetNonuniformFieldTracking();


//-------------------------------------------------------------------------
// Setting the cuts for the V0 and cascade finding
// The values of the cuts below are "reasonable" for central PbPb events
//------------------------------------------------------------------------- 

  Double_t cuts[]={33,  // max allowed chi2
                  0.1, // min allowed impact parameter for the 1st daughter 
                  0.1, // min allowed impact parameter for the 2nd daughter
                  0.05, // max allowed DCA between the daughter tracks
                  0.99, // max allowed cosine of V0's pointing angle
                  0.9,  // min radius of the fiducial volume
                  100   // max radius of the fiducial volume
  };
  AliV0vertexer::SetDefaultCuts(cuts);

  Double_t cts[]={33.,  // max allowed chi2
                 0.05,  // min allowed V0 impact parameter 
                 0.008, // "window" around the Lambda mass 
                 0.035, // min allowed bachelor's impact parameter 
                 0.1,  // max allowed DCA between the V0 and the bachelor
                 0.9985,// max allowed cosine of the cascade pointing angle
                 0.9,   // min radius of the fiducial volume
                 100    // max radius of the fiducial volume
  };
  AliCascadeVertexer::SetDefaultCuts(cts);

  rec.SetUniformFieldTracking(kTRUE);

  gBenchmark->Start("Run");
  rec.Run();
  gBenchmark->Stop("Run");
  gBenchmark->Show("Run");
}
