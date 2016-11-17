import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# import custom modules
import read_data as rd
import time_analysis as ta
import utils

# read in random two_million rows
sample = pd.read_csv('../Data/Samples/train_two_million_random.csv')
# print first 20 rows
sample.head(20)

# generate bins of time interval 100 (histogram)
tgrps = ta.time_bins(sample,100,start=0,stop=800000)
# plot histogram (density of check-ins vs time)
plt.plot(tgrps.bin,tgrps.time)
plt.xlabel('time (?units)')
plt.ylabel('check-ins / 100 ?units')
plt.title('Check-ins over time for random 2-million samples')
plt.show()

# detrend data by applying boxcar smoothing filter
# twice -- once with a 10 unit window and then with
# a 50 unit window -- and taking the difference between the two
# and between the total signal and the smoothed signals
detrnd = ta.detrend(tgrps.bin, tgrps.time, window=(10,50))
# plot different stages of detrending
plt.plot(detrnd.time,detrnd.smooth1,'b')
plt.plot(detrnd.time,detrnd.smooth2,'k')
plt.plot(detrnd.time,detrnd.resid01,'g')
plt.plot(detrnd.time,detrnd.resid02,'r')
plt.plot(detrnd.time,detrnd.resid12,'c')
plt.legend(['smooth-1','smooth-2','resid-01','resid-02','resid12'], \
           loc=5, fontsize='small')
plt.xlabel('time (?units)')
plt.ylabel('check-ins / 100 ?units')
plt.title('Check-ins over time for random 2-million samples')
plt.show()

# fourier analyze the detrended smoothed signal
pspec = ta.powspec(detrnd.time,detrnd.resid12)
plt.plot(pspec.period, pspec.power)
plt.xlim((0,20000))
plt.xlabel('period (?units)')
plt.ylabel('check-in density spectral power')
plt.title('Power in detrended smoothed signal')
plt.show()

# fourier analyze the detrended total signal
pspec = ta.powspec(detrnd.time,detrnd.resid02)
plt.plot(pspec.period, pspec.power)
plt.xlim((0,20000))
plt.xlabel('period (?units)')
plt.ylabel('check-in density spectral power')
plt.title('Power in detrended total signal')
plt.show()

# histogram of check-ins by time-of-day (notwithstanding unknown start time of data)
# add feature 'timeofday' to dataframe:
sample['timeofday'] = [ta.time_to_timeofday(x) for x in sample.loc[:,'time']]
plt.hist((24./10000)*np.array(sample.timeofday), bins=24)
plt.xlim((0, 24))
plt.xlabel('Hour of Day')
plt.ylabel('Number of check-ins')
# very very little to see!!

# bar-chart of check-ins by day-of-week (notwithstanding unknown start time of data)
# add feature 'weekday' to dataframe:
sample['weekday'] = [ta.time_to_weekday(x) for x in sample.loc[:,'time']]
tab = utils.table(sample.weekday)
plt.bar([d for (d,num) in tab],[num for (d,num) in tab], align='center')
plt.xlim([-0.5,6.5])
plt.xlabel('Day of Week')
plt.ylabel('Number of check-ins')
# also very little to see indeed!

# lets make a scatter plot of check-ins coloured by quarter of day
# plot first thousand check-ins by time of day
# add variable for block of day of each check-in
sample['block'] = [ta.timeofday_to_blockofday(ta.time_to_timeofday(x)) for x in sample.loc[:,'time']]
nplotpoints = 30000
morning = sample.loc[0:nplotpoints,['x','y','time']][sample.block==1]
midday = sample.loc[0:nplotpoints,['x','y','time']][sample.block==2]
evening = sample.loc[0:nplotpoints,['x','y','time']][sample.block==3]
night = sample.loc[0:nplotpoints,['x','y','time']][sample.block==4]
plt.scatter(morning.x, morning.y, c='r', s=8, alpha=0.3, linewidth=0)
plt.scatter(midday.x, midday.y, c='g', s=8, alpha=0.3, linewidth=0)
plt.scatter(evening.x, evening.y, c='b', s=8, alpha=0.3, linewidth=0)
plt.scatter(night.x, night.y, c='k', s=8, alpha=0.3, linewidth=0)
plt.xlabel('x')
plt.ylabel('y')
plt.xlim((0,10))
plt.ylim((0,10))
plt.legend(['morning','midday','evening','night'],loc=1)
plt.show()
# nothing stands out!
