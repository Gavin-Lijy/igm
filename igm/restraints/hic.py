from __future__ import division, print_function

import numpy as np

from .restraint import Restraint
from ..model.forces import HarmonicUpperBound

import h5py

class HiC(Restraint):
    """
    Object handles Hi-C restraint
    
    Parameters
    ----------
    actdist_file : activation distance file
        
    contactRange : int
        defining contact range between 2 particles as contactRange*(r1+r2)
    """
    
    def __init__(self, actdist_file, contactRange=2, k=1.0):
        
        self.contactRange = contactRange
        self.k = k
        self.forceID = []
        self._load_actdist(actdist_file)
    #-
    
    def _load_actdist(self,actdist):
        self.actdist = ActivationDistanceDB(actdist)
    
    def _apply(self, model):
        
        for (i, j, d) in self.actdist:
            
            # calculate particle distances for i, j
            # if ||i-j|| <= d then assign a bond for i, j
            if model.particles[i] - model.particles[j] <= d : 
                
                # harmonic mean distance
                dij = self.contactRange*(model.particles[i].r + 
                                         model.particles[j].r)
                
                f = model.addForce(HarmonicUpperBound((i, j), dij, self.k, 
                                                      note=Restraint.HIC))
                self.forceID.append(f)
            #-
        #-
    #=
    
    
#==

class ActivationDistanceDB(object):
    """
    HDF5 activation distance iterator
    """
    
    
    def __init__(self, actdist_file, chunk_size = 10000):
        self.h5f = h5py.File(actdist_file,'r')
        self._n = len(self.h5f['row'])
        
        self.chunk_size = min(chunk_size, self._n)
        
        self._i = 0
        self._chk_i = chunk_size
        self._chk_end = 0
        
    def __len__(self):
        return self._n
    
    def __iter__(self):
        return self
    
    def next(self):
        if self._i < self._n:
            self._i += 1
            self._chk_i += 1
            
            if self._chk_i >= self.chunk_size:
                self._load_next_chunk()
            
            return (self._chk_row[self._chk_i],
                    self._chk_col[self._chk_i],
                    self._chk_data[self._chk_i])
        else:
            self._i = 0
            self._chk_i = self.chunk_size
            self._chk_end = 0
            raise StopIteration()
    
    def _load_next_chunk(self):
        self._chk_row = self.h5f['row'][self._chk_end : self._chk_end + self.chunk_size]
        self._chk_col = self.h5f['col'][self._chk_end : self._chk_end + self.chunk_size]
        self._chk_data = self.h5f['data'][self._chk_end : self._chk_end + self.chunk_size]
        self._chk_end += self.chunk_size
        self._chk_i = 0
        
        
