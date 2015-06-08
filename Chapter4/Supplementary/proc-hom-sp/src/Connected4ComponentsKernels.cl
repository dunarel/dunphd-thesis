// created on Nov 22, 2012

/**
 * @author root
 */
#pragma OPENCL EXTENSION cl_khr_global_int32_base_atomics : enable

inline uint popcnt(const uint i) {
   uint n;
   asm("popc.b32 %0, %1;" : "=r"(n) : "r" (i));
   return n;
 }


float concat4Jaccard(__global uint4 * a,
                     __global uint4 * b,
                     __global uint4 * c,
                     __global uint4 * d) {
                        
     float jacc = 0;


      //uint4 a4,b4,c4,d4;
     
     uint4 auc,bud,anc,dnb,cna,bnd,aic,bid;
   

        int A_union_C = 0;
        int B_union_D = 0;
        int A_and_not_C = 0;
        int D_and_not_B = 0;
        int C_and_not_A = 0;
        int B_and_not_D = 0;

        int A_intersect_C = 0;
        int B_intersect_D = 0;

        for (int i = 0; i < 2; i++) {
            //a4 = vload4(i,a);
            //b4 = vload4(i,b);
            //c4 = vload4(i,c);
            //d4 = vload4(i,d);
            
            auc = a[i] | c[i]; 
            //A_union_C = A_union_C + popcount(auc.s0) + popcount(auc.s1) + popcount(auc.s2) + popcount(auc.s3);
            A_union_C = A_union_C + popcnt(auc.s0) + popcnt(auc.s1) + popcnt(auc.s2) + popcnt(auc.s3);
        
            bud = b[i] | d[i];
            B_union_D = B_union_D + popcnt(bud.s0) + popcnt(bud.s1) + popcnt(bud.s2) + popcnt(bud.s3);
            
            anc = a[i] & (~c[i]);
            A_and_not_C = A_and_not_C + popcnt(anc.s0) + popcnt(anc.s1) + popcnt(anc.s2) + popcnt(anc.s3);
            
            dnb = d[i] & (~b[i]);
            D_and_not_B = D_and_not_B + popcnt(dnb.s0) + popcnt(dnb.s1) + popcnt(dnb.s2) + popcnt(dnb.s3);

            cna = c[i] & (~a[i]);
            C_and_not_A = C_and_not_A + popcnt(cna.s0) + popcnt(cna.s1) + popcnt(cna.s2) + popcnt(cna.s3);
            
            bnd = b[i] & (~d[i]);
            B_and_not_D = B_and_not_D + popcnt(bnd.s0)+ popcnt(bnd.s1)+ popcnt(bnd.s2)+ popcnt(bnd.s3);
             
            aic = a[i] & c[i];
            A_intersect_C = A_intersect_C + popcnt(aic.s0)+ popcnt(aic.s1)+ popcnt(aic.s2)+ popcnt(aic.s3);
            
            bid = b[i] & d[i];
            B_intersect_D = B_intersect_D + popcnt(bid.s0)+ popcnt(bid.s1)+ popcnt(bid.s2)+ popcnt(bid.s3);
           
        }

         
        
        int unionBits = (A_union_C * B_union_D) - (A_and_not_C * D_and_not_B) - (C_and_not_A * B_and_not_D);
        //printf("A_union_C: %i \n", A_union_C); 
        //printf("B_union_D: %i \n", B_union_D); 
        //printf("(A_union_C * B_union_D): %i \n", (A_union_C * B_union_D)); 
        //
        //printf("A_union_C: %i \n", A_and_not_C); 
        //printf("B_union_D: %i \n", D_and_not_B); 
        //printf("(A_union_C * B_union_D): %i \n", (A_and_not_C * D_and_not_B)); 
        
        int intersectBits = A_intersect_C * B_intersect_D;
        jacc = (float) intersectBits / (float) unionBits;
        
        //if (jacc >= 0.75) {
        //  printf("test_val: %f \n", jacc); 
        //}
  
        return jacc;
                
        
        
}

kernel void detect_4edges(__global uint4 * from_ptr, 
                          __global uint4 * to_ptr,
                          __global int * edge_nb_max_ptr, 
                          __global int * edge_nb_ptr, 
                          int size,
                          __global int * edge_list_from_ptr, 
                          __global int * edge_list_to_ptr) {
    int gid_u = get_global_id(0);
    int gid_v = get_global_id(1); 
    
    int edge_id = 0;
    
    if (gid_u >= size || gid_v >= size || gid_u >= gid_v) {
        return;
    }
    
    (void) atomic_inc(&edge_nb_max_ptr[0]);
    
    __global uint4* a_ptr = from_ptr + (gid_u *2);
    __global uint4* b_ptr = to_ptr + (gid_u *2);
    __global uint4* c_ptr = from_ptr + (gid_v *2);
    __global uint4* d_ptr = to_ptr + (gid_v *2);
    
    
    
    float jacc_direct = concat4Jaccard(a_ptr,
                                       b_ptr,
                                       c_ptr,
                                       d_ptr);
    float jacc_inverse = concat4Jaccard(a_ptr,
                                  b_ptr,
                                  d_ptr,
                                  c_ptr);
                                    
     
    //when we have a result get index
    //and store the edge in the edge list
    if (jacc_direct > 0.75 || jacc_inverse > 0.75) {
     //printf("kernel gid_u: %i, gid_v: %i, edge_nb_max_ptr: %i, testVal %f \n", gid_u, gid_v, edge_nb_max_ptr[0], testVal);        
     edge_id = atomic_inc(&edge_nb_ptr[0]);
     edge_list_from_ptr[edge_id] = gid_u;
     edge_list_to_ptr[edge_id] = gid_v;
    
     //printf("kernel gid_u: %i, gid_v: %i, edge_id: %i, &edge_nb_ptr[0]: %i \n", gid_u, gid_v, edge_id, edge_nb_ptr[0]);        
     //printf("kernel gid_u: %i, gid_v: %i, edge_id: %i \n", gid_u, gid_v, edge_id);        
    }
    
    
    
    
    //for(int x=0; x< 8; x++) {
    //   int j = id * 8 + x; 
       
    // printf("kernel id: %i, x: %i, from_ptr: %i \n", id, x, from_ptr[j]);
    //}
    
    //a[id] = 0;
}


kernel void realign_4framgs(__global uint4 * from_ptr, 
                            __global uint4 * to_ptr,
                            int size,
                            __global int * frgm_source_ptr,
                            __global int * frgm_status_ptr) {

 int gid = get_global_id(0);

    if (gid >= size) {
        return;
    }
    
  //printf("size: %i, \n", size);

  int u = frgm_source_ptr[gid];
  int v = gid;
  //printf("kernel gid: %i, \n", gid);
  //printf("kernel u: %i, v: %i \n", u, v);

  __global uint4* a_ptr = from_ptr + (u *2);
  __global uint4* b_ptr = to_ptr + (u *2);
  __global uint4* c_ptr = from_ptr + (v *2);
  __global uint4* d_ptr = to_ptr + (v *2);
    
    
    
    float jacc_direct = concat4Jaccard(a_ptr,
                                       b_ptr,
                                       c_ptr,
                                       d_ptr);
    float jacc_inverse = concat4Jaccard(a_ptr,
                                        b_ptr,
                                        d_ptr,
                                        c_ptr);
                                    
    
    //1 = root = Reference
    //2 = same order = Original
    //3 = reverse = Realigned
    frgm_status_ptr[gid] = select(select(3, 2 ,(jacc_direct > jacc_inverse)), 1 ,( u == v));
    
    
      
}



__kernel void displ_matrix(__global int* a, int na, int nb) 
{
    int i = get_global_id(0);
    if (i >= 1)
        return;
        
   for(int x=0; x< 20; x++) {
     //printf("x: %d \n", a[x]);
    }
    

   for(int j=0; j< 5; j++) {
     //printf("i: %d, j: %d \n", i, j);
     //printf("a: %d \n", a[i*4]);
    }
    
}
