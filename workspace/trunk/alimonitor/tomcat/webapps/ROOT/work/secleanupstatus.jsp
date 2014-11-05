<%@ page import="lazyj.*,java.util.*,java.io.*,alien.catalogue.*" %><%
    response.setContentType("text/plain");

    //utils.ReduceReplicas.executor.setMaximumPoolSize(32);
    //utils.ReduceReplicas.executor.setCorePoolSize(32);

    out.println("Active threads  : "+utils.ReduceReplicas.executor.getActiveCount());
    out.println("Queue size      : "+utils.ReduceReplicas.executor.getQueue().size());
    out.println("Completed tasks : "+utils.ReduceReplicas.executor.getCompletedTaskCount());
    out.println("Freed space     : "+Format.size(utils.ReduceReplicas.getSuccessfullyRemovedSpace()));
    out.println("Delay free space: "+Format.size(utils.ReduceReplicas.getUnsuccessfullyRemovedSpace()));
    out.println("Kept space      : "+Format.size(utils.ReduceReplicas.getKeptSpace()));
%>