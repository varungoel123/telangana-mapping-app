import numpy as np
import pandas as pd
from pandas import DataFrame, Series
import itertools
from itertools import combinations
#import os
#os.listdir('C:\\Users\\malaniaayushi\\Desktop\\Resra Docs\\shiny_download_app\\data')

files =['agcensus_05_crop_district','agcensus_05_lhc_district','agcensus_11_crop_district','agcensus_11_landholdings_district'
        'nrega_expenditure_district','nrega_general_details_district','rkvy_12_14_district'] 
path ='C:\\Users\\malaniaayushi\\Desktop\\Resra Docs\\shiny_download_app\\data\\%s'

for file_name in files:

    data = pd.read_csv(path % file_name +'.csv') #read data file
    data_hierarchy = pd.read_csv(path % 'hierarchy_lookup_' + file_name +'.csv') #read corresponding hierarchy file for the above data file
    fixed_variables = ['state_code','district_code'] # assign fixed variables which are same for all the files
    # assign non fixed variables - take unique values from level_code column in hierarchy file and subtract fixed variables from it
    non_fixed_variables =list(set(data_hierarchy.level_code)-set(fixed_variables)) 
    rearranged_columns=list(data.columns)
    # to give range starting from 0 to total number of non fixed variables
    
    combinations=range(0,len(list(non_fixed_variables)))
    data_all = pd.DataFrame(columns=rearranged_columns) #empty dataset with columns in the same sequence as original dataset
    grouping_vars=fixed_variables + non_fixed_variables 
    
    for x in combinations:
        # combinations function will give every sort of pairing among non fixed variables 
        var_list = list(itertools.combinations(non_fixed_variables,x))
        for y in var_list:
            data_ff =data[:] #copy original data to data_ff
            variables= fixed_variables + list(y) 
            data_ff =data_ff.groupby(variables).sum() # groupby fixed variables and different combinations of non fixed variables
            data_ff=data_ff.reset_index() # convert multi index to single dimensional index
            data_ff[list(set(grouping_vars)-set(variables))]=9999 # assign 9999 value to the remaining non fixed variable which are not covered in group by statement
            data_all=data_all.append(data_ff) 
    data_all=pd.concat([data, data_all]) # concatenate new data with the original data
    data_all=data_all[rearranged_columns] # to get columns in original sequence
    output_filename = file_name+'_all.csv'
    data_all.to_csv(path % output_filename, index=False) # write data at desired location
    
# Now manipulate hierarchy files
#create empty dataframe with same columns as hierarchy files
    data_hierarchy_all = pd.DataFrame(columns=['level_code', 'level_description', 'var_code', 'var_description']) 
    
    for z in non_fixed_variables:
        #add rows with var description ='All'
        data_hh ={'level_code':[z],'level_description':list(set(data_hierarchy.level_description[data_hierarchy.level_code==z])), 'var_code':[9999],'var_description':['ALL']}
        data_hh=DataFrame(data_hh) #convert the above into dataframe
        data_hierarchy_all=data_hierarchy_all.append(data_hh) # append these additional rows into empty dataframe created before 
    data_h = pd.concat([data_hierarchy, data_hierarchy_all]) 
    output_hierarchy_filename = 'hierarchy_lookup_' + file_name +'_all.csv'
    data_h.to_csv(path % output_hierarchy_filename, index=False) # write data at desired location
