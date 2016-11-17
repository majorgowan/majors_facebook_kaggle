import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import time

# data prep
t0 = time.time()

# load training samples
sample = pd.read_csv('../Data/Samples/train_first_1000000.csv')

# divide domain into 10 by 100 squares
sample['xbin'] = [int(x) for x in sample.x]
sample['ybin'] = [int(10*y) for y in sample.y]

# divide time into day and night
def daynight(time):
    tod = time % 1440
    if (tod > 1440/4 and tod < 3*1440/4):
        return 0
    else:
        return 1
sample['daynight'] = [daynight(t) for t in sample.time]

# divide domain into dayofweek
def dayofweek(time):
    return (time / 1440) % 7
sample['dayofweek'] = [dayofweek(t) for t in sample.time]

# divide domain into quarter-years
def quarteryear(time):
    return (time / (365*1440)) % 4
sample['quarter'] = [quarteryear(t) for t in sample.time]

# sort samples
#sample.sort_values(by=['xbin','ybin','daynight','dayofweek','quarter'],inplace=True)
# group samples
sample_groups = sample.groupby(['xbin','ybin','quarter'])

print('Elapsed time in dataprep: ' + str(time.time() - t0) + ' seconds')
# end data prep
