TGraph* GetStats(const char* tag, Int_t& events, Float_t& avg, Float_t& max, Float_t& slope)
{
  TGraph *graph = (TGraph*) gPad->GetPrimitive("Graph");
  
  if (graph && graph->GetN() > 0)
  {
    events = (Int_t) graph->GetX()[graph->GetN()-1];
    avg = graph->GetMean(2);
    max = graph->GetY()[graph->GetN()-1];
    
    // fit second half
    graph->Fit("pol1", "", "", events / 2, events);
    func = graph->GetFunction("pol1");
    if (func)
      slope = func->GetParameter(1);
    
    Printf("MLTRAIN-%s %lld %f %f %f", tag, events, avg, max, slope);
  }
  
  return (TGraph*) graph->Clone();
}

void extract_syswatch(const char* fileName = "syswatch.root")
{
  gStyle->SetTitleOffset(1.3, "y");
  
  TFile::Open(fileName);
  tree = (TTree*) gFile->Get("syswatch");
  if (!tree)
    return;
  
  c = new TCanvas("c", "c", 1000, 800);
  c->Divide(2, 2);
  
  Long64_t nEvents = -1;
  
  Float_t avgResMem = -1;
  Float_t maxResMem = -1;
  Float_t slopeResMem = -1;
  
  Float_t avgVirtualMem = -1;
  Float_t maxVirtualMem = -1;
  Float_t slopeVirtualMem = -1;
  
  Float_t wallTime = -1;
  Float_t cpuTime = -1;
  
  c->cd(1);
  tree->Draw("pI.fMemResident:id0", "id1==-1");
  graphRes = GetStats("Resident:", nEvents, avgResMem, maxResMem, slopeResMem);
  
  tree->Draw("pI.fMemVirtual:id0", "id1==-1");
  graphVirt = GetStats("Virtual:", nEvents, avgVirtualMem, maxVirtualMem, slopeVirtualMem);
  
  graphVirt->SetMinimum(0);
  graphVirt->SetMarkerColor(1);
  graphVirt->SetMarkerStyle(24);
  graphVirt->SetTitle("Memory");
  graphVirt->GetXaxis()->SetTitle("Events");
  graphVirt->GetYaxis()->SetTitle("Memory (MB)");
  graphVirt->Draw("AP");
  
  graphRes->SetMarkerColor(4);
  graphRes->SetMarkerStyle(25);
  graphRes->Draw("PSAME");
  
  legend = new TLegend(0.35, 0.15, 0.62, 0.3);
  legend->SetFillColor(0);
  legend->AddEntry(graphVirt, "Virtual", "P");
  legend->AddEntry(graphRes, "Resident", "P");
  legend->Draw();
  
  c->cd(2);
  tree->Draw("pI.fCpuUser:id0", "id1==-1");
  TGraph *cpuGraph = (TGraph*) gPad->GetPrimitive("Graph")->Clone();
  if (cpuGraph && cpuGraph->GetN() > 0)
    cpuTime = cpuGraph->GetY()[cpuGraph->GetN()-1];

  tree->Draw("stampSec:id0", "id1==-1");
  TGraph *wallGraph = (TGraph*) gPad->GetPrimitive("Graph")->Clone();
  if (wallGraph && wallGraph->GetN() > 0 && cpuGraph->GetN() > 0)
  {
    Double_t min = wallGraph->GetY()[0];
    Double_t max = wallGraph->GetY()[wallGraph->GetN()-1];
    
    // the first sample is not exactly at t=0 and we do not know it. as an approximation add the cpu time of sample 0 to the wall time start value
    min -= cpuGraph->GetY()[0];
    
    wallTime = max - min;
    
    for (Int_t i=0; i<wallGraph->GetN(); i++)
      wallGraph->GetY()[i] -= min;
  }
  
  Printf("MLTRAIN-Walltime: %f", wallTime);
  Printf("MLTRAIN-Cputime: %f", cpuTime);

  wallGraph->SetTitle("Time Consumption");
  wallGraph->GetXaxis()->SetTitle("Events");
  wallGraph->GetYaxis()->SetTitle("Time (s)");
  wallGraph->SetMinimum(0);
  wallGraph->SetMarkerColor(4);
  wallGraph->SetMarkerStyle(25);
  wallGraph->Draw("AP");

  cpuGraph->SetMinimum(0);
  cpuGraph->SetMarkerColor(1);
  cpuGraph->SetMarkerStyle(24);
  cpuGraph->Draw("PSAME");

  legend = new TLegend(0.35, 0.15, 0.62, 0.3);
  legend->SetFillColor(0);
  legend->AddEntry(cpuGraph, "CPU Time", "P");
  legend->AddEntry(wallGraph, "Wall time", "P");
  legend->Draw();

  c->cd(3);
  cpuGraphClone = (TGraph*) cpuGraph->Clone();
  wallGraphClone = (TGraph*) wallGraph->Clone();
  efficiency = new TGraph;
  if (cpuGraphClone->GetN() == wallGraphClone->GetN())
  {
    for (Int_t i=1; i<cpuGraphClone->GetN(); i++)
    {
      // walltime does not start at exactly 0 leading to an efficency > 1 at the beginning. skip first seconds.
      if (wallGraphClone->GetY()[i] > 0)
      {
	Double_t deltaCpu = cpuGraphClone->GetY()[i] - cpuGraphClone->GetY()[i-1];
	Double_t deltaWall = wallGraphClone->GetY()[i] - wallGraphClone->GetY()[i-1];
	
	if (deltaWall > 0)
	  efficiency->SetPoint(efficiency->GetN(), cpuGraphClone->GetX()[i], deltaCpu / deltaWall);
      }
      else
      {
	cpuGraphClone->RemovePoint(i);
	wallGraphClone->RemovePoint(i);
	i--;
      }
    }
  }
  
  efficiency->SetTitle("CPU Efficiency");
  efficiency->GetYaxis()->SetTitle("CPU time / Wall time");
  efficiency->GetXaxis()->SetRangeUser(0, efficiency->GetXaxis()->GetXmax());
  efficiency->GetYaxis()->SetRangeUser(0, 1);
  efficiency->SetMarkerColor(1);
  efficiency->SetMarkerStyle(24);
  efficiency->Draw("AP");
  
  Float_t cpuEff = efficiency->GetMean(2);
  
  Printf("MLTRAIN-CpuEfficiency: %f", cpuEff);
  
  c->SaveAs("syswatch.png");
}

void DivideGraphs(TGraph* graph1, TGraph* graph2)
{
//   graph1->Print();
//   graph2->Print();

  for (Int_t bin1 = 0; bin1 < graph1->GetN(); bin1++)
  {
    Float_t x = graph1->GetX()[bin1];

    Int_t bin2 = 0;
    for (bin2 = 0; bin2<graph2->GetN(); bin2++)
      if (graph2->GetX()[bin2] >= x)
        break;

    if (bin2 == graph2->GetN())
            bin2--;

    if (bin2 > 0)
      if (TMath::Abs(graph2->GetX()[bin2-1] - x) < TMath::Abs(graph2->GetX()[bin2] - x))
        bin2--;

    if (graph1->GetY()[bin1] == 0 || graph2->GetY()[bin2] == 0 || bin2 == graph2->GetN())
    {
//       Printf("%d %d removed", bin1, bin2);
      graph1->RemovePoint(bin1--);
      continue;
    }

    Float_t graph2Extrapolated = graph2->GetY()[bin2];
    if (TMath::Abs(x - graph2->GetX()[bin2]) > 0.0001)
    {
//       Printf("%f %f %d %d not found", x, graph2->GetX()[bin2], bin1, bin2);
      graph1->RemovePoint(bin1--);
      continue;
    }

    Float_t value = graph1->GetY()[bin1] / graph2Extrapolated;
//     Float_t error = value * TMath::Sqrt(TMath::Power(graph1->GetEY()[bin1] / graph1->GetY()[bin1], 2) + TMath::Power(graph2->GetEY()[bin2] / graph2->GetY()[bin2], 2));

    graph1->GetY()[bin1] = value;
//     graph1->GetEY()[bin1] = error;

//     Printf("%d %d %f %f %f %f", bin1, bin2, x, graph2Extrapolated, value, error);
  }
}