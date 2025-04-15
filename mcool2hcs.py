import alabtools, numpy, scipy
import argparse 
import numpy as np

def fmax_norm(self,method = 'NM'):

        fmax = None
        matrix = self.matrix.toarray()
        if method == 'NM':#method neighbour max
            fmax = np.zeros(len(self))
            for chrom in np.unique(self.index.chrom):
                pos_list = self.index.get_chrom_pos(chrom)
                cstart = pos_list[0]
                cend = pos_list[-1]+1 #cend is increased by one
                for i in range(cstart+1,cend-1):
                    fmax[i] = max(matrix[i,i+1],matrix[i,i-1]) 
                    # use max instead of min in case it's near centromere or end of of chrom so that fmax is too small
                fmax[cstart] = matrix[cstart,cstart+1] #p telomere
                fmax[cend-1] = matrix[cend-1,cend-2] #q telomere
        K = matrix.shape[0]
        c_matrix = np.zeros_like(matrix)
        for i in range(K):
            for j in range(K):
                denom = max(fmax[i], fmax[j])
                # min to max
                c_matrix[i, j] = min(matrix[i, j] / denom,1) if denom > 0 else 0
        return c_matrix

def process_cool(cool, resolution, genome, hcs,usechr):
    # Load .cool file with given resolution and genome
    m = alabtools.Contactmatrix(cool, resolution=resolution, genome=genome,usechr=usechr)
    A = fmax_norm(m)
    spm = scipy.sparse.csr_matrix(A)
    diag = spm.diagonal()
    m.matrix = alabtools.matrix.sss_matrix((spm.data, spm.indices, spm.indptr, diag), shape=spm.shape)
   
    # Save processed matrix to .hcs file
    m.save(hcs)
    print(f"Processed matrix saved to {hcs}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert .mcool to .hcs with specified resolution and genome.")
    parser.add_argument("--mcool", type=str, required=True, help="Path to the input .mcool file")
    parser.add_argument("--resolution", type=int, required=True, help="Resolution for processing the .mcool file")
    parser.add_argument("--genome", type=str, required=True, help="Genome reference")
    parser.add_argument("--hcs", type=str, required=True, help="Output .hcs file path")
    parser.add_argument("--usechr", type=str, required=True, help="Output .hcs file path")
    
    args = parser.parse_args()
    process_cool(args.mcool, args.resolution, args.genome, args.hcs, args.usechr)