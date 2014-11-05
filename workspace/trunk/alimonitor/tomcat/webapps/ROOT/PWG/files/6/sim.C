void sim(char *config = "/afs/cern.ch/user/c/coppedis/public/PDC07/Config_PDC07_b03.C", Int_t nev){

  AliSimulation *sim = new AliSimulation(config);
    sim->SetWriteRawData("ZDC");
    TStopwatch timer;
    timer.Start();
    sim->Run(nev);
    timer.Stop();
    timer.Print();

}
