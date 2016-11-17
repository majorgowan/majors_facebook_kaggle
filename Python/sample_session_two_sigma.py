import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# load training samples
sample = pd.read_csv('../Data/Samples/train_first_1000000.csv')
# load all centres
medians = pd.read_csv('../Data/place_id_medians.csv')
# load (not-random) candidate neighbours file
sample_two_sigma = pd.read_csv('../Fortran/train_two_sigma_neighbours.csv')

tp = 0

# find all check-ins for same place_id
first = sample[sample.place_id == sample.at[tp,'place_id']].loc[:,['x','y']]
first_med = medians[medians.place_id == sample.at[tp,'place_id']].loc[:,['x','y']]

# lookup place_ids of near neighbour centres
words = [int(w) for w in sample_two_sigma.at[sample.at[tp,'row_id'],'place_id'].split(' ')]
# positions of centres
nbrs_meds = medians[[(s in words) for s in medians.place_id]].loc[:,['x','y']]
# all check-ins associated with those centres
nbrs = sample[[(s in words) for s in sample.place_id]].loc[:,['x','y']]

# scatter plot
plt.scatter(nbrs.x,nbrs.y,s=15,c='r',alpha=0.5,linewidth=0.1)
plt.scatter(first.x,first.y,s=15,c='b',alpha=0.5,linewidth=0.1)
plt.scatter(nbrs_meds.x,nbrs_meds.y,s=25,c='k',alpha=1,linewidth=0.1)
plt.scatter(first_med.x,first_med.y,s=40,c='g',alpha=1,linewidth=0.1)
plt.scatter(sample.at[tp,'x'],sample.at[tp,'y'],marker='x',s=40,c='k',alpha=1,linewidth=1)
plt.legend(['nbrs','siblings','nbr_centres','mother','me!'])
plt.show()

