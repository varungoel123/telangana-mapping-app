# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

import pandas as pd
from pandas import DataFrame, Series
path_to_files = '/home/isb/Documents/rainfall/'
data_ppt = pd.read_csv(path_to_files+ 'yearly_rf_IMD_1981-2013.csv')
data_code = pd.read_excel(path_to_files + 'apy_state_dist_codes_data_dictionary.xlsx')
data_code = data_code[['district_code','state_code']]
data_anom = pd.read_csv(path_to_files + 'imd_rf_anom_yearly_1981_2010.csv')
data_anom = data_anom.drop(['yr_10_below','yr_20_below'], axis=1)
#print data_anom.columns
#data = data.rename(columns={'dist_census2011_code': 'district_code'})
### For anomly data ####
#print data_anom.columns[1]
#print len(data_anom.columns)
cols = {}

for i in range(1,len(data_anom.columns)):
    columns = data_anom.columns[i]
    #print type(columns)
    #columns_renamed= columns[5:]
    col_dict = {columns:columns[5:]}
    cols.update(col_dict)
#print cols

    #print type(columns_renamed)
data_anom = data_anom.rename(columns = cols)
data_anom = data_anom.rename(columns={'dist_census2011_code': 'district_code'})
data_all = pd.DataFrame()
#print len(data_anom.columns)
for i in range(1, len(data_anom.columns)):
    data_anom_tall = pd.melt(data_anom, id_vars = ['district_code'], value_vars = data_anom.columns[i], var_name ='year', value_name = 'rainfall_anom')
    data_all = data_all.append(data_anom_tall)
#print data_all
    
#print data_anom_tall
#for i in range(sample = pd.melt(data, id_vars = ['district_code'], value_vars = [headers[i]], var_name ='year', value_name = 'rainfall')
dfinal_anom=pd.merge(data_code,data_all,on=['district_code'])
dfinal_anom[:10]

# <codecell>

cols = {}
for i in range(1,len(data_ppt.columns)):
    columns = data_ppt.columns[i]
    #print type(columns)
    #columns_renamed= columns[5:]
    col_dict = {columns:columns[3:]}
    cols.update(col_dict)
data_ppt = data_ppt.rename(columns = cols)
data_all = pd.DataFrame()
for i in range(1, len(data_ppt.columns)):
    data_ppt_tall = pd.melt(data_ppt, id_vars = ['district_code'], value_vars = data_ppt.columns[i], var_name ='year', value_name = 'rainfall')
    data_all = data_all.append(data_ppt_tall)
#print data_all
dfinal_ppt=pd.merge(data_code,data_all,on=['district_code'])
dfinal_ppt[:10]

# <codecell>

dfinal_anom = dfinal_anom[['district_code','year','rainfall_anom']]
data_final = pd.merge(dfinal_ppt, dfinal_anom, on = ['district_code', 'year'])
data_final.to_csv(path_to_files + 'data_total.csv', index=False)
#telangana 532-541

# <codecell>

rainfall_tel = pd.read_csv(path_to_files + 'rainfall_telangana.csv')
rainfall_tel

# <codecell>


    

# <codecell>


# <codecell>


# <codecell>


