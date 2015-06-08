/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.uqam.doct.proc.hom.ex;

import java.util.concurrent.Executors;
import java.util.concurrent.ThreadPoolExecutor;

/**
 *
 * @author root
 */
public class Server {

    private ThreadPoolExecutor executor;

    public Server(int nbThreads) {
        executor = (ThreadPoolExecutor) Executors.newFixedThreadPool(nbThreads);
    }

    public void executeTask(Runnable task) {
        System.out.printf("Server: A new task has arrived\n");
        executor.execute(task);
        System.out.printf("Server: Pool Size: %d\n", executor.getPoolSize());
        System.out.printf("Server: Active Count: %d\n", executor.getActiveCount());
        System.out.printf("Server: Completed Tasks: %d\n", executor.getCompletedTaskCount());
        System.out.printf("Server: Task Count: %d\n",executor.getTaskCount());
    }

    public void endServer() {
        executor.shutdown();
        System.out.printf("Server: Final Task Count: %d\n",executor.getTaskCount());
    }
}
