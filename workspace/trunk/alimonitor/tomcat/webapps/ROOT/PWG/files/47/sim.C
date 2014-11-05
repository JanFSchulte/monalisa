void sim(Int_t nev=150)
{
     gSystem->Load("liblhapdf.so");      // Parton density functions
     gSystem->Load("libEGPythia6.so");   // TGenerator interface
     gSystem->Load("libpythia6.so");     // Pythia
     gSystem->Load("libAliPythia6.so");  // ALICE specific implementations
     AliSimulation Sim;
     Sim.SetMakeDigits("T0 VZERO");
     Sim.SetMakeSDigits("");
     Sim.SetMakeDigitsFromHits("");
     Sim.SetWriteRawData("T0 VZERO", "raw.root",kTRUE);
     Sim.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-14-Release/Ideal/");
     Sim.SetRunHLT("");

          TStopwatch timer;
          timer.Start();
          Sim.Run(nev);
          timer.Stop();
          timer.Print();
}
