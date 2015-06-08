// created on Nov 22, 2012

/**
 * @author root
 */


float concat1Jaccard(__global uint* a,
                     __global uint* b,
                     __global uint* c,
                     __global uint* d) {
                        
     float jacc = 0.0;

        int A_union_C = 0;
        int B_union_D = 0;
        int A_and_not_C = 0;
        int D_and_not_B = 0;
        int C_and_not_A = 0;
        int B_and_not_D = 0;

        int A_intersect_C = 0;
        int B_intersect_D = 0;

        for (int i = 0; i < 8; i++) {
            
            
            A_union_C += popcount(a[i]  | c[i] );
        
            
            B_union_D += popcount(b[i]  | d[i] );
            
       
            A_and_not_C += popcount(a[i] & (~c[i]));
            
            D_and_not_B += popcount(d[i] & (~b[i]));

            C_and_not_A += popcount(c[i] & (~a[i]));
            B_and_not_D += popcount(b[i] & (~d[i]));

            A_intersect_C += popcount(a[i] & c[i]);
            B_intersect_D += popcount(b[i] & d[i]);

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



kernel void detect_1edges(__global uint * from_ptr, 
                          __global uint * to_ptr,
                          __global uint * edge_nb_max_ptr, 
                          __global uint * edge_nb_ptr, 
                        int size) {
    int gid_u = get_global_id(0);
    int gid_v = get_global_id(1); 
    
    if (gid_u >= size || gid_v >= size || gid_u >= gid_v) {
        return;
    }
    
    (void) atomic_inc(&edge_nb_max_ptr[0]);
    
    __global uint* a_ptr = from_ptr + (gid_u *8);
    __global uint* b_ptr = to_ptr + (gid_u *8);
    __global uint* c_ptr = from_ptr + (gid_v *8);
    __global uint* d_ptr = to_ptr + (gid_v *8);
    
    
    
    float jacc_direct = concat1Jaccard(a_ptr,
                                       b_ptr,
                                       c_ptr,
                                       d_ptr);
    float jacc_inverse = concat1Jaccard(a_ptr,
                                        b_ptr,
                                        d_ptr,
                                        c_ptr);
                                    
      
    if (jacc_direct > 0.75 || jacc_inverse > 0.75) {
     //printf("kernel gid_u: %i, gid_v: %i, edge_nb_max_ptr: %i, testVal %f \n", gid_u, gid_v, edge_nb_max_ptr[0], testVal);        
      (void) atomic_inc(&edge_nb_ptr[0]);
    }
    
    
    
    
    //for(int x=0; x< 8; x++) {
    //   int j = id * 8 + x; 
       
    // printf("kernel id: %i, x: %i, from_ptr: %i \n", id, x, from_ptr[j]);
    //}
    
    //a[id] = 0;
}

__kernel void add_floats(__global const float* a, __global const float* b, __global float* out, int n) 
{
    int i = get_global_id(0);
    if (i >= n)
        return;

    out[i] = a[i] + b[i];
}

__kernel void fill_in_values(__global float* a, __global float* b, int n) 
{
    int i = get_global_id(0);
    if (i >= n)
        return;

    a[i] = cos((float)i);
    b[i] = sin((float)i);
}

__kernel void displ_matrix(__global int* a, int na, int nb) 
{
    int i = get_global_id(0);
    if (i >= 1)
        return;
        
   for(int x=0; x< 20; x++) {
     printf("x: %d \n", a[x]);
    }
    

   for(int j=0; j< 5; j++) {
     printf("i: %d, j: %d \n", i, j);
     printf("a: %d \n", a[i*4]);
    }
    
}
