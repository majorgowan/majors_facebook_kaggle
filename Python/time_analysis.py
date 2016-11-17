def time_bins(df,interval,start=0,stop=800000):
    import numpy as np
    tdf = df.loc[:,['time']]
    nbins = int((stop-start)/interval)+1
    bins = np.linspace(start,stop,nbins)
    groups = tdf.groupby(np.digitize(tdf.time,bins)).count()
    groups['bin'] = bins[:len(groups)]
    return groups
    
def detrend(time, data, window=(10,50)):
    import numpy as np
    import pandas as pd
    smooth = np.convolve(data,np.ones(2*window[0]+1,)/(2.*window[0]+1.),mode='valid')
    verysmooth = np.convolve(smooth,np.ones(2*window[1]+1,)/(2.*window[1]+1.),mode='valid')
    resid01 = np.array(data[(sum(window)):-(sum(window))]) - smooth[window[1]:-window[1]]
    resid12 = smooth[window[1]:-window[1]] - verysmooth
    resid02 = np.array(data[(sum(window)):-(sum(window))]) - verysmooth
    return pd.DataFrame({'time': time[sum(window):-(sum(window))], \
                         'smooth1': smooth[window[1]:-window[1]], \
                         'smooth2': verysmooth, \
                         'resid01': resid01, \
                         'resid02': resid02, \
                         'resid12': resid12}) 

def powspec(time, data):
    import numpy as np
    import pandas as pd
    resid = np.array(data) - np.mean(data)
    # axis for power spectrum
    trange = np.array(time)[-1]-np.array(time)[0]
    period = trange*np.ones(len(resid),) / range(1,len(resid)+1)
    fff = np.fft.fft(resid) / len(resid)
    power = (fff * (fff.conj())).real / len(resid)
    return pd.DataFrame({'period': period[:len(period)/2], \
                         'power': power[:len(period)/2]})

def time_to_timeofday(t, period = 10000):
    return t % period

def timeofday_to_blockofday(tod):
    return 1*int((tod >= 1000) & (tod < 3500)) + \
           2*int((tod >= 3500) & (tod < 6000)) + \
           3*int((tod >= 6000) & (tod < 8500)) + \
           4*int((tod < 1000) | (tod >= 8500))

def time_to_weekday(t, period = 10000):
    return int(7*(float(t % (7*period))/(7*period)))

def clockdiff(t1, t2, period = 10000):
    tod1, tod2 = time_to_timeofday(t1), time_to_timeofday(t2)
    return min((tod1+period-tod2) % period, \
               (tod2+period-tod1) % period)

