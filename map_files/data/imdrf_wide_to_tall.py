import pandas as pd
from pandas import DataFrame, Series
path_to_files = '/home/isb/Documents/rainfall/' #path to all files
data_ppt = pd.read_csv(path_to_files+ 'yearly_rf_IMD_1981-2013.csv') # ppt data for 1981-2013
data_code = pd.read_excel(path_to_files + 'apy_state_dist_codes_data_dictionary.xlsx') # codebook
data_code = data_code[['district_code','state_code']] # only need state_code and district code from codebook
data_anom = pd.read_csv(path_to_files + 'imd_rf_anom_yearly_1981_2010.csv') # anomaly data for 1981-2010
data_anom = data_anom.drop(['yr_10_below','yr_20_below'], axis=1) #dropping columns with extra info which is not required
cols = {}


for i in range(1,len(data_anom.columns)): # changes column names from anom_1981 to 1981
    columns = data_anom.columns[i]
    #print type(columns)
    #columns_renamed= columns[5:]
    col_dict = {columns:columns[5:]} 
    cols.update(col_dict)

    #print type(columns_renamed)
data_anom = data_anom.rename(columns = cols) #renames columns
data_anom = data_anom.rename(columns={'dist_census2011_code':'district_code'}) #rename district code column
data_all = pd.DataFrame() #create empty dataframe
#print len(data_anom.columns)

for i in range(1, len(data_anom.columns)):
    data_anom_tall = pd.melt(data_anom, id_vars = ['district_code'], value_vars = data_anom.columns[i], var_name ='year', value_name='rainfall_anom')
    data_all = data_all.append(data_anom_tall)
    
#data_all[data_all.district_code == 536]

dfinal_anom=pd.merge(data_code,data_all,on=['district_code'])
#dfinal_anom[dfinal_anom.district_code == 536]
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

dfinal_anom = dfinal_anom[['district_code','year','rainfall_anom']]

data_final = pd.merge(dfinal_ppt,dfinal_anom, how ='left', on = ['district_code', 'year'])

data_final.to_csv(path_to_files + 'imd_rf_1981_2013_panindia.csv', index=False)
#telangana 532-541
data_tel = data_final[(data_final.district_code>=532) & (data_final.district_code<=541)]

#print data_tel[data_tel.district_code == 541]

data_tel.to_csv(path_to_files + 'tel_imd_rf_1981-2013_district.csv', index = False)
#rainfall_tel