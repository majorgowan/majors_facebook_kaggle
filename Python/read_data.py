def read_subset(filename,xlim=(0,10),ylim=(0,10),tlim=(0,790000)):
    import pandas as pd
    dftrain = pd.read_csv(filename, index_col = 'row_id')
    subset=dftrain[(dftrain.y>ylim[0]) & (dftrain.y<ylim[1]) \
                   & (dftrain.x>xlim[0]) & (dftrain.x<xlim[1]) \
                   & (dftrain.time>tlim[0]) & (dftrain.time<tlim[1])]
    subset.loc[:,'place_id'] = subset.loc[:,'place_id'].astype("category")
    return subset

def compute_stats(df,by='place_id'):
    import pandas as pd
    grouped = df.loc[:,['place_id','x','y','accuracy']].groupby(by)
    medians = grouped.median()
    means = grouped.mean()
    stds = grouped.std()
    counts = grouped.count()
    return {'median': medians, 'mean': means, 'std': stds, 'count': counts}

def get_stats(pp):
    import os.path
    import pandas as pd
    return {'median': pd.read_csv(os.path.join(pp,'place_id_medians.csv')), \
            'mean': pd.read_csv(os.path.join(pp,'place_id_means.csv')), \
            'std': pd.read_csv(os.path.join(pp,'place_id_stds.csv')), \
            'count': pd.read_csv(os.path.join(pp,'place_id_counts.csv'))}
