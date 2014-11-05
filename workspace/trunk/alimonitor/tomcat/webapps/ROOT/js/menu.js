function showMenu(){
	prefix="http://alimonitor.cern.ch";

	dMLMenu = new dTree('dMLMenu');
		dMLMenu.add(0,-1,'ALICE Repository <a href="'+prefix+'/xml.jsp"><img border=0 src="/images/xml.gif"></a>','/');

		dMLMenu.add(5,0,'Google Map',prefix+'/map.jsp');
		
		dMLMenu.add(6,0,'Shifter\'s dashboard', prefix+'/dashboard/');
		
		dMLMenu.add(7,0,'Run Condition Table', prefix+'/configuration/');
		dMLMenu.add(8,0,'Production Overview', prefix+'/configuration/pot.jsp');

            	dMLMenu.add(9,0,'Production info', null);
            	    dMLMenu.add(9005,9,'Run view', prefix+'/runview/');
		    dMLMenu.add(9002,9,'RAW production cycles', prefix+'/production/raw.jsp');
		    dMLMenu.add(9003,9,'RAW activities', prefix+'/prod/?t=3');
		    dMLMenu.add(9005,9,'LEGO trains', prefix+'/trains/');
		    dMLMenu.add(9004,9,'Analysis train', prefix+'/prod/');
		    dMLMenu.add(9000,9,'MC production cycles', prefix+'/job_details.jsp');
		    dMLMenu.add(9001,9,'MC production requests', prefix+'/PWG/');
		    
                dMLMenu.add(10,0,'Job Information', prefix+'/show?page=jobStatus.html');
            	    dMLMenu.add(100,'Jobs details', prefix+'/job_events.jsp');

            	    dMLMenu.add(101,10,'Site views', null);
            		dMLMenu.add(1011,101,'Summary plots',prefix+'/display?page=jobStatusSites_TOTALS');
			dMLMenu.add(1012,101,'Job states', prefix+'/display?page=jobStatusSites_RUNNING');
			dMLMenu.add(1013,101,'Jobs per site', prefix+'/display?page=jobs_per_site');
			dMLMenu.add(1014,101,'Jobs per site table',prefix+'/stats?page=current_job_status');
			//dMLMenu.add(1016,101,'JA LCGStatus', prefix+'/display?page=JA_LCGStatus/side');
			dMLMenu.add(1017,101,'Resource usage', prefix+'/display?page=jobResUsageSum_time_cpu');
		    dMLMenu.add(102,10,'User views', null);
			dMLMenu.add(1021,102,'Summary plots',prefix+'/display?page=jpu/jobs_per_user');
			dMLMenu.add(1022,102,'Jobs status',prefix+'/display?page=jpu/jpu_RUNNING');
			dMLMenu.add(1023,102,'Grid packages',prefix+'/packages/');
			dMLMenu.add(1024,102,'Quotas',prefix+'/users/quotas.jsp');
		    dMLMenu.add(103,10,'Task queue');
			dMLMenu.add(1031,103,'Task queue summary', prefix+'/display?page=jobStatusCS_run_params');
		        dMLMenu.add(1032,103,'Jobs in TQ table', prefix+'/job_stats.jsp');
		        dMLMenu.add(1033,103,'Matching per site', prefix+'/display?page=jobs/matching_per_site');
		        dMLMenu.add(1034,103,'Matching histogram', prefix+'/display?page=jobs/histogram');
		    dMLMenu.add(104,10,'Job timings');
			dMLMenu.add(1041, 104, 'By site', prefix+'/Correlations?page=timings/persite');
			dMLMenu.add(1042, 104, 'Per user', prefix+'/Correlations?page=timings/peruser');
		    dMLMenu.add(107,10,'Memory profiles');
			dMLMenu.add(1070, 107, 'Offending jobs', prefix+'/display?page=memory/offenders');
			dMLMenu.add(1071, 107, 'By site', prefix+'/display?page=jps/mem_combined');
			dMLMenu.add(1072, 107, 'Per user', prefix+'/display?page=jpu/mem_combined');
			dMLMenu.add(1073, 107, 'Current jobs', prefix+'/memory/');
		    dMLMenu.add(105,10,'Federation views');
			dMLMenu.add(1051, 105, 'Resources', prefix+'/display?page=federations/histogram_time_run_si2k');
			dMLMenu.add(1052, 105, 'Jobs', prefix+'/display?page=federations/histogram_jobs_done');
		    dMLMenu.add(106,10,'JobAgents');
			dMLMenu.add(1061, 106, 'CE status', prefix+'/display?page=ja');
			dMLMenu.add(1062, 106, 'Active JAs', prefix+'/display?page=ja_status');
			dMLMenu.add(1063, 106, 'Cumulative JAs', prefix+'/display?page=ja_status_R');
		    dMLMenu.add(108,10,'Running trend', prefix+'/trend.jsp');


		dMLMenu.add(20,0,'SE Information','');
		    dMLMenu.add(201,20,'Status',prefix+'/stats?page=SE/table');
    		    //dMLMenu.add(202,20,'Traffic',prefix+'/display?page=seTraffic_mbytes');
		    dMLMenu.add(203,20,'Files',prefix+'/display?page=seTraffic_files_rd');


		    dMLMenu.add(207,20,'xrootd','');
			dMLMenu.add(2071,207,'SEs overview',prefix+'/display?page=xrootdse/SEs');
			dMLMenu.add(2072,207,'Per SE details','');
			    dMLMenu.add(20721,2072,'Traffic',prefix+'/display?page=xrootdse/by_se');
			    dMLMenu.add(20722,2072,'Load',prefix+'/display?page=xrootdse/by_se_load');
			    dMLMenu.add(20723,2072,'Sockets',prefix+'/display?page=xrootdse/by_se_sockets');
		
		    dMLMenu.add(208, 20, 'CERN Castor2x', prefix+'/display?page=castor2/hist');
		    
		    dMLMenu.add(209,20,'AFs','');
			dMLMenu.add(2091,209,'Overview',prefix+'/display?page=PROOF/SEs');
			dMLMenu.add(2092,209,'Details','');
			    dMLMenu.add(20921,2092,'Traffic',prefix+'/display?page=PROOF/by_se');
			    dMLMenu.add(20922,2092,'Load',prefix+'/display?page=PROOF/by_se_load');
			    dMLMenu.add(20923,2092,'Sockets',prefix+'/display?page=PROOF/by_se_sockets');

		dMLMenu.add(30,0,'Services', null);
		    dMLMenu.add(301,30,'Central Services',prefix+'/show?page=racks.html');
			dMLMenu.add(3011,301,'Central machines',prefix+'/stats?page=machines/machines');
			dMLMenu.add(3012,301,'APIServers', prefix+'/display?page=api_sessions');
			dMLMenu.add(3013,301,'DAQ Registration', prefix+'/display?page=DAQ2/daq_size');
			dMLMenu.add(3014,301,'ML Repository', prefix+'/info.jsp');
			dMLMenu.add(3015,301,'UPSs', prefix+'/stats?page=ups/ups');
			dMLMenu.add(3016,301,'Sensors', prefix+'/stats?page=machines/ipmi');
			dMLMenu.add(3017,301,'VirtualBox', prefix+'/stats?page=machines%2Fvirtualbox');
			dMLMenu.add(3018,301,'Build machines', prefix+'/stats?page=machines%2Fbuild');
			dMLMenu.add(3019,301,'Network traffic', prefix+'/display?page=machines/net/uplink');
			dMLMenu.add(3010,301,'Catalogue stats', prefix+'/display?page=catalogue/rows');
			
		    dMLMenu.add(302,30,'Site Services',null);
			dMLMenu.add(3020,302,'Site overview',prefix+'/siteinfo/');
			dMLMenu.add(3021,302,'VO Boxes',prefix+'/stats?page=vobox_status');
			dMLMenu.add(3022,302,'Services status',prefix+'/stats?page=services_status');
			dMLMenu.add(3023,302,'MonaLisa',prefix+'/stats?page=siteMLstatus');
			dMLMenu.add(3024,302,'Proxies',prefix+'/stats?page=proxies');
			dMLMenu.add(3025,302,'Packages',prefix+'/packages/list.jsp');
			dMLMenu.add(3026,302,'VoBox temp', prefix+'/temp.jsp');
			dMLMenu.add(3027,302,'SAM Tests', prefix+'/sam/sam.jsp');
			
    		dMLMenu.add(40,0,'Network Traffic',null);
    		    dMLMenu.add(41,40,'Incomming',prefix+'/display?page=site_in_traffic_hist');
    		    dMLMenu.add(42,40,'Outgoing',prefix+'/display?page=site_out_traffic_hist');
    		    dMLMenu.add(43,40,'Internal',prefix+'/display?page=site_int_traffic_hist');
    		    dMLMenu.add(44,40,'Inter-Site',prefix+'/display?page=site_intsite_traffic_hist');
    		    dMLMenu.add(45, 40, 'Bandwidth tests', prefix+'/speed/');

		
		dMLMenu.add(60, 0, 'FTD Transfers',prefix+'/show?page=ftdStatus.html');
		    dMLMenu.add(601, 60, 'RAW replication', prefix+'/transfers');
		    dMLMenu.add(601, 60, 'Transfer states', prefix+'/display?page=FTD/CS');
		    dMLMenu.add(602, 60, 'Transfer speed', prefix+'/display?page=FTD/SE');
		    dMLMenu.add(603, 60, 'FTD efficiency', 'http://dashb-alice-job.cern.ch/dashboard/data/fts/index.html', null, '_blank');
			
		dMLMenu.add(70, 0, 'CAF Monitoring', null);
		    dMLMenu.add(700, 70, 'RAW Data Reconstruction', prefix+'/raw_reco_status.jsp');
		    dMLMenu.add(701, 70, 'Machine views', null);
		        dMLMenu.add(7011, 701, 'Status table', prefix+'/stats?page=CAF2/table');
			dMLMenu.add(7012, 701, 'Parameter view', prefix+'/display?page=CAF2/parameter');
			dMLMenu.add(7013, 701, 'Machine details', prefix+'/display?page=CAF2/machine');
		    //dMLMenu.add(702, 70, 'Query type views', null);
		//	dMLMenu.add(7021, 702, 'Aggregation', prefix+'/display?page=CAF2/query_value');
		//	dMLMenu.add(7022, 702, 'Detailed QT view', prefix+'/display?page=CAF2/query_type');
		//	dMLMenu.add(7023, 702, 'Network traffic', prefix+'/stats?page=CAF2/network');
		//	dMLMenu.add(7024, 702, 'Traffic history', prefix+'/display?page=CAF2/traffic');
		    //dMLMenu.add(703, 70, 'Disk quotas', null);
		//	dMLMenu.add(7031, 703, 'DataSet Manager', prefix+'/stats?page=CAF2%2Fprocessing');
		//	dMLMenu.add(7032, 703, 'Quota overview', prefix+'/display?page=CAFQuota/disk_groups_rt');
		//	dMLMenu.add(7033, 703, 'Groups details', prefix+'/display?page=CAFQuota/disk_users_rt');
		    dMLMenu.add(704, 70, 'CPU quotas', prefix+'/caf/cpuquota.jsp');
		    //dMLMenu.add(705, 70, 'Sessions', null);
	    	      //  dMLMenu.add(7051, 705, 'User', prefix+'/display?page=CAF2/users');
			//dMLMenu.add(7052, 705, 'Group', prefix+'/display?page=CAF2/groups');
			//dMLMenu.add(7053, 705, 'Totals', prefix+'/display?page=CAF2/totals');
		    dMLMenu.add(705,70,'Datasets',prefix+'/stats?page=CAF2/datasets');

		dMLMenu.add(80, 0, 'SHUTTLE', prefix+'/show?page=shuttle.html');
		    dMLMenu.add(801, 80, 'Production@P2', prefix+'/shuttle.jsp?instance=PROD');
		    dMLMenu.add(802, 80, 'Test setup', prefix+'/shuttle.jsp');
		    dMLMenu.add(803, 80, 'Host monitoring', prefix+'/display?page=shuttle/machine');
		
		dMLMenu.add(91, 0, 'Build system');
		    dMLMenu.add(911, 91, 'AliRoot benchmarks', prefix+'/bits/bits_benchmark.jsp');
		    
		dMLMenu.add(92, 0, 'HepSpec');
		    dMLMenu.add(921, 92, 'Overview', prefix+'/hepspec/');
		    dMLMenu.add(922, 92, 'Per site', prefix+'/hepspec/site.jsp');
		    
		dMLMenu.add(100, 0, 'Dynamic charts', prefix+'/correlations/');

		document.write(dMLMenu);
}
