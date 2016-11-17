import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import time

# import custom modules
import read_data as rd
import time_analysis as ta
import utils
import FrumanNeighbours as fn

# read in summary stats for full data
stats = rd.get_stats('../Data')
# plot centres of all place-id check-in "clouds"
# very popular places
biguns = stats['median'][(stats['count'].x>1000)]
len(biguns)
plt.scatter(stats['median'].x,stats['median'].y,s=2,linewidth=0,alpha=0.2)
plt.scatter(biguns.x,biguns.y,s=8,linewidth=0,alpha=0.5,c='r')
plt.xlim((0,10));
plt.ylim((0,10));
plt.title('Median locations of check-ins to places with >1000 check-ins (red) <1000 (blue)')
plt.show()

# read in random two_million rows
sample = pd.read_csv('../Data/Samples/train_two_million_random.csv')
# print first 20 rows
sample.head(20)

#############################################################
################################ ULTRASIMPLE MODEL ##########
# consider ultra-simple model: classify a check-in based on the
# proximity to the median location of the check-ins to each place_id
# in the training set
t0 = time.time()
neighbours = []
correct = []
for isamp in xrange(10000):
    neighbours.append(fn.nearest_n(sample.loc[isamp,['x','y']], \
                                   stats['median'], \
                                   n=3, \
                                   dmax=0.01))
    correct.append(sample.at[isamp,'place_id'] in neighbours[-1])
    #print(str(isamp) + ': ' + str(sample.at[isamp,'place_id']) + \
    #        ' . . . ' + str(neighbours[-1]) + ' . . . ' + \
    #        str(sample.at[isamp,'place_id'] in neighbours[-1]))

print("done in %0.3fs." % (time.time() - t0))

# print out accuracy:
print('Correct: ' + str(np.sum(correct)) + \
        ' out of ' + str(len(correct)) + \
        ' (' + str(float(np.sum(correct))/len(correct)) + ')' )

# compare results by count
counts = [int(stats['count'][stats['count'].place_id==sample.at[ii,'place_id']].x) \
                       for ii in xrange(10000)]
counts_correct = [c for i,c in enumerate(counts) if correct[i]] 
counts_incorrect = [c for i,c in enumerate(counts) if not correct[i]] 
plt.hist([counts_correct, counts_incorrect], bins=10)
plt.legend(['correct','incorrect'])
plt.show()
# not much difference in performance between high- and low-count place_ids

# plot locations of correct and incorrect
x_samp = [float(stats['median'][stats['median'].place_id==sample.at[ii,'place_id']].x) \
                       for ii in xrange(10000)]
y_samp = [float(stats['median'][stats['median'].place_id==sample.at[ii,'place_id']].y) \
                       for ii in xrange(10000)]
x_corr = [x for i,x in enumerate(x_samp) if correct[i]] 
x_incorr = [x for i,x in enumerate(x_samp) if not correct[i]] 
y_corr = [y for i,y in enumerate(y_samp) if correct[i]] 
y_incorr = [y for i,y in enumerate(y_samp) if not correct[i]] 
plt.scatter(x_corr, y_corr, c='b', s=10, alpha=0.5, linewidth=0)
plt.scatter(x_incorr, y_incorr, c='r', s=10, alpha=0.5, linewidth=0)
plt.xlim((0,10));
plt.ylim((0,10));
plt.title('Median locations of correctly (blue) and incorrectly (red) classified check-ins')
plt.show()

#############################################################
################################ EFFECT OF SCALING ##########
# repeat for scaled x-y coordinates
# determine scale factors (std of x- and y- positions of check-ins to same place_id)
x_y_scale = fn.scale_x_y(stats, thresh=50, method='median')
# change to try scaling y slightly less drastically
# x_y_scale = (0.1,1.0)
sample_scaled = fn.rescale_x_y(sample, x_y_scale=x_y_scale, inplace=False)
medians_scaled = fn.rescale_x_y(stats['median'].loc[:,['x','y','place_id']], x_y_scale=x_y_scale, inplace=False)

t0 = time.time()
neighbours_sc = []
correct_sc = []
for isamp in xrange(1000):
    neighbours_sc.append(fn.nearest_n(sample_scaled.loc[isamp,['x','y']], \
                                      medians_scaled, \
                                      n=3, \
                                      dmax=2.0))
    correct_sc.append(sample_scaled.at[isamp,'place_id'] in neighbours_sc[-1])
    #print(str(isamp) + ': ' + str(sample_scaled.at[isamp,'place_id']) + \
    #        ' . . . ' + str(neighbours_sc[-1]) + ' . . . ' + \
    #        str(sample_scaled.at[isamp,'place_id'] in neighbours_sc[-1]))

print("done in %0.3fs." % (time.time() - t0))

# print out accuracy:
print('Correct: ' + str(np.sum(correct_sc)) + \
        ' out of ' + str(len(correct_sc)) + \
        ' (' + str(float(np.sum(correct_sc))/len(correct_sc)) + ')' )

# this does worse!!
# compare results from scaled and unscaled:
print('Scaled wrong and unscaled wrong: ' + \
        str(np.sum((not correct[ii] and not b) for ii,b in enumerate(correct_sc))))
print('Scaled wrong and unscaled right: ' + \
        str(np.sum((correct[ii] and not b) for ii,b in enumerate(correct_sc))))
print('Scaled right and unscaled wrong: ' + \
        str(np.sum((not correct[ii] and b) for ii,b in enumerate(correct_sc))))
print('Scaled right and unscaled right: ' + \
        str(np.sum((correct[ii] and b) for ii,b in enumerate(correct_sc))))
print('Scaled right or unscaled right: ' + \
        str(np.sum((correct[ii] or b) for ii,b in enumerate(correct_sc))) + ' / ' + str(len(correct_sc)))


###################################################################################
################################ EXPAND THE NEIGHBOURHOOD #########################
t0 = time.time()
neighbours = []
for isamp in xrange(1000):
    neighbours.append(fn.nearest_n(sample.loc[isamp,['x','y']], \
                                   stats['median'], \
                                   n=10, \
                                   dmax=0.01))

print("done in %0.3fs." % (time.time() - t0))

