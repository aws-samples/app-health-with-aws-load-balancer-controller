#!/usr/local/bin/python

import numpy as np
import sys
import os
from multiprocessing import Pool


_matrix_dim=int(os.environ['MATRIX_DIM'])
_num_core=int(os.environ['NUM_CORE'])

# Generate two matrices
matrix1 = np.random.rand(_matrix_dim, _matrix_dim)
matrix2 = np.random.rand(_matrix_dim, _matrix_dim)

def matrix_multiply(row_col):
  i, j = row_col
  return np.dot(matrix1[i,:], matrix2[:,j])

if __name__ == '__main__':

  # Define the number of processes to use
  num_processes = _num_core

  # Create a pool of processes
  pool = Pool(processes=num_processes)

  # Create a list of row-column pairs to calculate
  row_col_list = [(i, j) for i in range(matrix1.shape[0]) for j in range(matrix2.shape[1])]

  # Use the pool to map the row-column pairs to their resulting values
  results = pool.map(matrix_multiply,row_col_list)

  # Reshape the results into a matrix
  result_matrix = np.array(results).reshape(matrix1.shape[0], matrix2.shape[1])
  print(result_matrix)
  sys.stdout.flush()
