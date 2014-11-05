void sim() 
{
  AliSimulation sim;
  sim.SetRunGeneration(kTRUE);
  sim.SetRunSimulation(kTRUE);
  sim.SetMakeSDigits("TRD TOF PHOS HMPID EMCAL MUON FMD ZDC PMD T0 VZERO");
  sim.SetMakeDigitsFromHits("ITS TPC");
  sim.SetWriteRawData("ITS TPC TRD TOF","raw.root",kTRUE);
  sim.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-12-Release/Full/");
  sim.SetRunHLT("");
  sim.SetQA(kFALSE);

  sim.Run(1);
}
