#if !defined(__CINT__) || defined(__MAKECINT__)

#include <iostream>

#include <TFile.h>
#include <TTree.h>
#include <TString.h>
#include <TGrid.h>
#include <TSystem.h>

#include "AliESDEvent.h"

#endif
// #define VERBOSEARGS
// simrun.C

void simrun() {

  int nrun = 0;
  int nevent = 0;
  int nnevents = 0;
  int seed = 0;

  char sseed[1024];
  char srun[1024];
  char srawfile[1024];
  char sesdfile[1024];
  char sevent[1024];
  char snevents[1024];
  char sprocess[1024];
  char sfield[1024];
  char senergy[1024];

  sprintf(srun,"");
  sprintf(sevent,"");
  sprintf(sprocess,"");
  sprintf(sfield,"");
  sprintf(senergy,"");

  for (int i=0; i< gApplication->Argc();i++){
#ifdef VERBOSEARGS
    printf("Arg  %d:  %s\n",i,gApplication->Argv(i));
#endif
    if (!(strcmp(gApplication->Argv(i),"--run")))
      nrun = atoi(gApplication->Argv(i+1));
    sprintf(srun,"%d",nrun);

    if (!(strcmp(gApplication->Argv(i),"--rawfile")))
      sprintf(srawfile,"alien://%s", gApplication->Argv(i+1));

    if (!(strcmp(gApplication->Argv(i),"--event")))
      nevent = atoi(gApplication->Argv(i+1));
    sprintf(sevent,"%d",nevent);

    if (!(strcmp(gApplication->Argv(i),"--nevents")))
      nnevents = atoi(gApplication->Argv(i+1));
    sprintf(snevents,"%d",nnevents);

    if (!(strcmp(gApplication->Argv(i),"--process")))
      sprintf(sprocess, gApplication->Argv(i+1));

    if (!(strcmp(gApplication->Argv(i),"--field")))
      sprintf(sfield,gApplication->Argv(i+1));

    if (!(strcmp(gApplication->Argv(i),"--energy")))
      sprintf(senergy,gApplication->Argv(i+1));

  }

	TString tsesdfile(srawfile);
	tsesdfile.ReplaceAll("raw","ESDs/pass2");
	tsesdfile.ReplaceAll(".root","/AliESDs.root");
  sprintf(sesdfile,tsesdfile.Data());

  gSystem->Load("libVMC");
  gSystem->Load("libMinuit");
  gSystem->Load("libTree");
  gSystem->Load("libProofPlayer");
  gSystem->Load("libXMLParser");
  gSystem->Load("libPhysics");

  gSystem->Load("libSTEERBase"); 
  gSystem->Load("libESD");


	// Try to get number of events from esd file if available
	// Open esd file if available
	TFile* esdFile = 0;
	TTree* treeESD = 0;
	AliESDEvent* esd = 0;
	if ( sesdfile && (strlen(sesdfile)>0)) {
		TGrid::Connect("alien://");
		esdFile = TFile::Open(sesdfile);
		if (esdFile) {
			esdFile->GetObject("esdTree", treeESD);
			if (treeESD) {
				nnevents = treeESD->GetEntriesFast();
				sprintf(snevents,"%d",nnevents);
			}
		}
	}
	
	sprintf(snevents,"%d",1);
  //  seed = nrun * 100000 + nevent;
  sprintf(sseed,"%d",seed);

  if (seed==0) {
    fprintf(stderr,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stderr,"!!!!  WARNING! Seeding variable for MC is 0          !!!!\n");
    fprintf(stderr,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
  } else {
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stdout,"!!!  MC Seed is %d \n",seed);
    fprintf(stdout,"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
  }
  
	FileStat_t fileStat;
	
  // set the seed environment variable
  gSystem->Setenv("CONFIG_SEED",sseed);
  gSystem->Setenv("CONFIG_RUN_TYPE",sprocess); // kPythia6 or kPhojet
  gSystem->Setenv("CONFIG_FIELD",sfield);      // kNoField or k5kG
  gSystem->Setenv("CONFIG_ENERGY",senergy);    // 900 or 10000 (GeV)
  gSystem->Setenv("DC_RUN",srun); // Not used in Config.C
  gSystem->Setenv("DC_RAWFILE",srawfile); // Not used in Config.C
  gSystem->Setenv("DC_ESDFILE",sesdfile); // Not used in Config.C
  gSystem->Setenv("DC_EVENT",sevent); // Not used in Config.C
  gSystem->Setenv("DC_NEVENTS",snevents); // Not used in Config.C
  
  // Needed to produce simulated RAW data
  gSystem->Setenv("ALIMDC_RAWDB1","./mdc1");
  gSystem->Setenv("ALIMDC_RAWDB2","./mdc2");
  gSystem->Setenv("ALIMDC_TAGDB","./mdc1/tag");
  gSystem->Setenv("ALIMDC_RUNDB","./mdc1/meta");
  cout<< "EMBRUN:: Run " << gSystem->Getenv("DC_RUN") 
      << " RawFile " << gSystem->Getenv("DC_RAWFILE") 
      << " EsdFile " << gSystem->Getenv("DC_ESDFILE") 
//      << " Event " << gSystem->Getenv("DC_EVENT") 
      << " N events " << gSystem->Getenv("DC_NEVENTS")
//      << " Generator "    << gSystem->Getenv("CONFIG_RUN_TYPE")
//      << " Field " << gSystem->Getenv("CONFIG_FIELD")
      << " Energy " << gSystem->Getenv("CONFIG_ENERGY")
      << endl;


  // background
  gSystem->Setenv("CONFIG_EMBEDDING","kBackground");

  cout<<">>>>> BACKGROUND PART <<<<<"<<endl;
  gSystem->Exec("mkdir Background");
  gSystem->Exec("cp Config.C Background/");
  gSystem->Exec("cp sim.C Background/");
  gSystem->ChangeDirectory("Background/");
  cout<<">>>>> CONVERTING RAW 2 SDIGITS <<<<<"<<endl;
  gSystem->Exec("aliroot -b -q sim.C > sim.log 2>&1");
  cout<<">>>>> CHECKING ALL WENT WELL <<<<<"<<endl;
	if (gSystem->GetPathInfo("MUON.SDigits.root",fileStat)||
			gSystem->GetPathInfo("ITS.SDigits.root",fileStat)) {
		cout << "Coversion of raw to sdigits failed!" << endl;
		return;
	}
		
//  gSystem->Exec("mv syswatch.log simwatch.log");
  gSystem->ChangeDirectory("../");
  

  // Simulate signal and embed into background
  gSystem->Setenv("CONFIG_EMBEDDING","kMerged");

  cout<<">>>>> EMBEDDING PART <<<<<"<<endl;
  cout<<">>>>> EMBEDDING SIG & BKG SDIGITS <<<<<"<<endl;
  cout<<">>>>> MERGED SIMULATION <<<<<"<<endl;
  gSystem->Exec("aliroot -b -q sim.C > sim.log 2>&1");
  gSystem->Exec("mv syswatch.log simwatch.log");
	cout<<">>>>> CHECKING ALL WENT WELL <<<<<"<<endl;
	if (gSystem->GetPathInfo("MUON.Digits.root",fileStat)||
			gSystem->GetPathInfo("ITS.Digits.root",fileStat)) {
		cout << "merging of sdigits failed!" << endl;
		return;
	}
  cout<<">>>>> MERGED RECONSTRUCTION <<<<<"<<endl;
  gSystem->Exec("aliroot -b -q rec.C > rec.log 2>&1");
  gSystem->Exec("mv syswatch.log recwatch.log");
	cout<<">>>>> TAG <<<<<"<<endl;
	gSystem->Exec("aliroot -b -q tag.C > tag.log 2>&1");
  cout<<">>>>> COPY BRANCHES FROM ORIGINAL ESD <<<<<"<<endl;
  gSystem->Exec("mv AliESDs.root AliESDsTmp.root");
  gSystem->Exec("aliroot -b -q CheckESD.C > check.log 2>&1");
	
  // Pure signal re-reconstruction
  gSystem->Setenv("CONFIG_EMBEDDING","kSignal");
  
  cout<<">>>>> SIGNAL ONLY PART <<<<<"<<endl;
  gSystem->Exec("mkdir Signal");
  gSystem->Exec("cp Config.C Signal/");
  gSystem->Exec("cp sim.C Signal/");
  gSystem->Exec("cp rec.C Signal/");
  gSystem->Exec("cp CheckESD.C Signal/");
  gSystem->Exec("cp *SDigits*.root Signal/");
  gSystem->Exec("cp Background/ITS.SDigits*.root Signal/"); //to reconstruct the vertex
  gSystem->Exec("cp galice.root Signal/");
  gSystem->Exec("cp Kinematics.root Signal/");
  gSystem->Exec("cp -a GRP Signal/");
  gSystem->ChangeDirectory("Signal/");
  cout<<">>>>> SIMULATION <<<<<"<<endl;
  gSystem->Exec("aliroot -b -q sim.C > sim.log 2>&1");
  gSystem->Exec("mv syswatch.log simwatch.log");
	cout<<">>>>> CHECKING ALL WENT WELL <<<<<"<<endl;
	if (gSystem->GetPathInfo("MUON.Digits.root",fileStat)||
			gSystem->GetPathInfo("ITS.Digits.root",fileStat)) {
		cout << "digits creation failed!" << endl;
		return;
	}
  cout<<">>>>> RECONSTRUCTION <<<<<"<<endl;
  gSystem->Exec("aliroot -b -q rec.C > rec.log 2>&1");
  gSystem->Exec("mv syswatch.log recwatch.log");
  cout<<">>>>> COPY BRANCHES FROM ORIGINAL ESD <<<<<"<<endl;
	gSystem->Exec("aliroot -b -q CheckESD.C > check.log 2>&1");
  gSystem->ChangeDirectory("../");

  cout<<">>>>> RENAMING SOME OUTPUT FILES <<<<<"<<endl;
  gSystem->Setenv("EMBFOLDER","Merged");
  gSystem->Exec("cp -a AliESDsTmp.root AliESDs$EMBFOLDER.root");

  gSystem->Setenv("EMBFOLDER","Signal");
  gSystem->Exec("cp -a $EMBFOLDER/sim.log sim$EMBFOLDER.log");
  gSystem->Exec("cp -a $EMBFOLDER/rec.log rec$EMBFOLDER.log");
	gSystem->Exec("cp -a $EMBFOLDER/check.log check$EMBFOLDER.log");
//  gSystem->Exec("cp -a $EMBFOLDER/galice.root galice$EMBFOLDER.root");
//  gSystem->Exec("cp -a $EMBFOLDER/raw.root raw$EMBFOLDER.root");
//  gSystem->Exec("cp -a $EMBFOLDER/Trigger.root Trigger$EMBFOLDER.root");
//  gSystem->Exec("cp -a $EMBFOLDER/Kinematics.root Kinematics$EMBFOLDER.root");
  gSystem->Exec("cp -a $EMBFOLDER/MUON.SDigits.root MUON.SDigits$EMBFOLDER.root");
  gSystem->Exec("cp -a $EMBFOLDER/MUON.Digits.root MUON.Digits$EMBFOLDER.root");
  gSystem->Exec("cp -a $EMBFOLDER/MUON.RecPoints.root MUON.RecPoints$EMBFOLDER.root");  
  gSystem->Exec("cp -a $EMBFOLDER/AliESDs.root AliESDs$EMBFOLDER.root");
//  gSystem->Exec("cp -a $EMBFOLDER/MUONhistos.root MUONhistos$EMBFOLDER.root");
//  gSystem->Exec("cp -a $EMBFOLDER/MUONefficiency.root MUONefficiency$EMBFOLDER.root");

  gSystem->Setenv("EMBFOLDER","Background");
  gSystem->Exec("cp -a $EMBFOLDER/sim.log sim$EMBFOLDER.log");
  gSystem->Exec("cp -a $EMBFOLDER/galice.root galice$EMBFOLDER.root");
  gSystem->Exec("cp -a $EMBFOLDER/MUON.SDigits.root MUON.SDigits$EMBFOLDER.root");

}
