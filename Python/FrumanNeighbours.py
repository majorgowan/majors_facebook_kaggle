# compute means, medians and stds for each
# place_id
def compute_stats(df,by='place_id'):
    import pandas as pd
    grouped = df.loc[:,['place_id','x','y','accuracy']].groupby(by)
    medians = grouped.median()
    means = grouped.mean()
    stds = grouped.std()
    counts = grouped.count()
    return {'median': medians, 'mean': means, 'std': stds, 'count': counts}

# rescale position based on median x-std
# bzw y-std for place_ids with at least thresh
# check-ins
def scale_x_y(stats, thresh=50, method='median'):
    return stats['std'][stats['count'].x>thresh].loc[:,['x','y']].median().tolist()

def rescale_x_y(df, x_y_scale=(1,1), inplace=False):
    if not inplace:
        df2 = df.copy()
        df2.loc[:,'x'] /= x_y_scale[0]
        df2.loc[:,'y'] /= x_y_scale[1]
        return df2
    else:
        df.loc[:,'x'] /= x_y_scale[0]
        df.loc[:,'y'] /= x_y_scale[1]
        return 0

# for each place_id, compute frequency of
# each time of day (fit 24 points to the
# histogram)


# for each test-point, find the place_ids
# within a (scaled) distance r(acc) of the
# check-in position of the test-point
def neighbourhood(test_x_y, centres, radius=1):
    # compute distance to each place_centre
    c_xy = centres.loc[:,['x','y']]
    distance = ((centres-test_x_y)**2).transpose().sum()
    return sorted([(d,centres.at[i,'place_id']) for i,d in enumerate(distance) if d <= radius**2]) 

def dist_to_centre(test_x_y, pid, centres):
    place_x_y = centres[centres.place_id == pid].loc[:,['x','y']]
    return float(((test_x_y - place_x_y)**2).transpose().sum())

def rank_to_centre(test_x_y, pid, centres):
    import numpy as np
    dtc = np.sqrt(dist_to_centre(test_x_y, pid, centres))
    nbrhd = neighbourhood(test_x_y, centres, radius=dtc)
    return len(nbrhd)

def nearest_n(test_x_y, centres, n=3, dmax=1):
    import numpy as np
    # compute distance to each place_centre
    c_xy = centres.loc[:,['x','y']]
    distance = ((centres-test_x_y)**2).transpose().sum()
    nearest = sorted([(d,centres.at[i,'place_id']) for i,d in enumerate(distance) if d <= dmax])[:n]
    return tuple([pid for (d,pid) in nearest])

# fit a linear regression model to 
# determine r(acc), i.e. size of net to 
# cast as a function of accuracy of test-point
# (for each test point calculate distance
# to centre of cloud corresponding to its
# place_id)


