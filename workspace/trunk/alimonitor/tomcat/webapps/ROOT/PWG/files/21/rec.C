void rec() {

    //gSystem->Load("libProof");
    //gSystem->Load("libGui");
    //gROOT->Macro("loadlibsrec.C");

    //new AliRun("gAlice","The ALICE Off-line Simulation Framework");

    AliReconstruction MuonRec("galice.root"); 

    MuonRec.SetInput("raw.root");

    MuonRec.SetRunLocalReconstruction("MUON ITS VZERO FMD");
    MuonRec.SetRunTracking("MUON ITS VZERO FMD");

    MuonRec.SetRunVertexFinder(kTRUE);

    MuonRec.SetFillESD("MUON VZERO FMD");
    MuonRec.SetWriteAOD();

    MuonRec.SetDefaultStorage("alien://Folder=/alice/simulation/2007/PDC07_v4-07-Rev-01/Ideal/CDB/?cacheFold=/tmp/CDBCache");

    TStopwatch timer;
    timer.Start();
    MuonRec.Run();
    timer.Stop();
    timer.Print();

}
