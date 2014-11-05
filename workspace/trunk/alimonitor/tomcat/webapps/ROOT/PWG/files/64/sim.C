void sim(Int_t nev=1) {

  AliSimulation simu;
  simu.SetDefaultStorage("alien://Folder=/alice/simulation/2008/v4-15-Release/Ideal/?cacheFold=/tmp/CDBCache?operateDisconnected=kFALSE");

  simu.SetSpecificStorage("GRP/GRP/Data",
			  Form("local://%s",gSystem->pwd()));


  TStopwatch timer;
  timer.Start();
  simu.Run(nev);
  timer.Stop();
  timer.Print();
}
