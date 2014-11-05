<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lazyj.*,alien.quotas.*"%><%
    lia.web.servlets.web.Utils.logRequest("START /admin/fquota.jsp", 0, request);

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
            
    final RequestWrapper rw = new RequestWrapper(request);
            
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage_admin.res");
    
    pMaster.modify("title", "File Quotas");
    pMaster.modify("class_quota", "_active");

    final Page p = new Page("admin/fquota.res");
    final Page pEl = new Page("admin/fquota_el.res");

    // ------- Operations ---------

    // --------- Display ---------

    List<FileQuota> quotas = QuotaUtilities.getFileQuotas();

    long lTotalCount = 0;
    long lTotalSize = 0;
    
    for (final FileQuota fq: quotas){
	pEl.modify("account", fq.user);
	
	pEl.modify("files_count", fq.nbFiles);
	pEl.modify("files_count_quota", fq.maxNbFiles);
	pEl.modify("files_count_ratio_int", String.valueOf(((long)100*fq.nbFiles)/fq.maxNbFiles));
	pEl.modify("files_count_ratio_real", String.valueOf(100d*fq.nbFiles/fq.maxNbFiles));
	pEl.modify("complement_files_count_ratio_int", String.valueOf(100-((long)100*fq.nbFiles)/fq.maxNbFiles));
	pEl.modify("complement_files_count_ratio_real", String.valueOf(100-(100d*fq.nbFiles)/fq.maxNbFiles));

	pEl.modify("total_size", fq.totalSize);
	pEl.modify("total_size_quota", fq.maxTotalSize);
	pEl.modify("total_size_ratio_int", 100*fq.totalSize / fq.maxTotalSize);
	pEl.modify("total_size_ratio_real", 100d*fq.totalSize / fq.maxTotalSize);
	pEl.modify("complement_total_size_ratio_int", 100-(100*fq.totalSize / fq.maxTotalSize));
	pEl.modify("complement_total_size_ratio_real", 100-(100d*fq.totalSize / fq.maxTotalSize));
	
	p.append(pEl);
	
	lTotalCount += fq.nbFiles;
	lTotalSize += fq.totalSize;
    }
    
    p.modify("total_count", lTotalCount);
    p.modify("total_size", lTotalSize);

    // --------- Close -----------
    
    pMaster.append(p);
    pMaster.write();
    
    String s = new String(baos.toByteArray());
    out.println(s);
    
    lia.web.servlets.web.Utils.logRequest("/admin/fquota.jsp", baos.size(), request);
%>