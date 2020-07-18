#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created

@author: nihatompi
"""


import pandas as pd
from shapely.geometry import Polygon

class Summary:
    
    def __init__(self, labels, yoloDf, manualDf, threshold):
        self.target_labels = labels
        self.yolo_df = yoloDf
        self.manual_df = manualDf
        self.threshold = threshold
        self.__setup__()
        
    def __setup__(self):
        if 'num' not in self.manual_df.columns and 'num' not in self.yolo_df.columns:        
            self.manual_df['num'] = self.manual_df['filenames'].apply(lambda x: int(x.split('_')[-1]))
            self.manual_df['filenames'] = self.manual_df['filenames'].apply(lambda x: x.split('_')[0])
            self.manual_df = self.manual_df.sort_values(['filenames', 'num'])
            
            self.yolo_df['num'] = self.yolo_df['filenames'].apply(lambda x: int(x.split('_')[-1]))
            self.yolo_df['filenames'] = self.yolo_df['filenames'].apply(lambda x: x.split('_')[0])
            self.yolo_df = self.yolo_df.sort_values(['filenames', 'num'])
        
        # creating an empty df for correct and incorrect classifications
        classif_dict = pd.DataFrame(columns=['correct_classif', 'incorrect_classif'], index=self.target_labels)
        self.classif_dict = classif_dict.fillna(0)
        
        # Person name
        self.person_list = list(range(1, 40))
        self.person_list = ['Person' + str(x) for x in self.person_list]
        
        # creating df for storing all the filenames of correct clasifications
        _index = []
        _index.extend(range(1))
        correct_classif_persons_df = pd.DataFrame(columns=['filenames'], index=_index)
        self.correct_classif_persons_df = correct_classif_persons_df.fillna(0)
        
        # creating df for storing all the filenames of incorrect clasifications
        incorrect_classif_persons_df = pd.DataFrame(columns=['filenames'], index=_index)
        self.incorrect_classif_persons_df = incorrect_classif_persons_df.fillna(0)
        
    def __append_classification__(self, label, dataFrame, outDataFrame):
        fileName = dataFrame[dataFrame['Label'] == label]['filenames'].values.tolist()
        fileNum = dataFrame[dataFrame['Label'] == label]['num'].values.tolist()
        outDataFrame.loc[len(outDataFrame)] = [fileName[0] + "_" + str(fileNum[0])]
        return outDataFrame
    
    def __get_polygon__(self, dataFrame):
        width = dataFrame["Width"].values.astype(int)[0] # int(float(dataFrame["width"].values)) # 
        height = dataFrame["Height"].values.astype(int)[0] # int(float(dataFrame["height"].values))
        xmin = dataFrame["x"].values.astype(int)[0] # int(float(dataFrame["x"].values))
        ymin = dataFrame["y"].values.astype(int)[0] # int(float(dataFrame["y"].values))
        xmax = xmin + width - 1
        ymax = ymin + height - 1
        return Polygon([(xmin, ymin), (xmax, ymin), (xmax, ymax), (xmin, ymax)])
    
    def compute(self):
        for _index, _person in enumerate(self.person_list):
            manualDf = self.manual_df[self.manual_df['filenames'] == _person]
            yoloDf = self.yolo_df[self.yolo_df['filenames'] == _person]
            
            for _imgNum in manualDf['num']:
                manualDfByNum = manualDf[manualDf['num'] == _imgNum]
                yoloDfByNum = yoloDf[yoloDf['num'] == _imgNum]
                
                for _label in manualDfByNum['Label']:
                    if _label not in yoloDfByNum['Label'].tolist():
                        self.classif_dict.loc[_label]['incorrect_classif'] += 1
                        self.incorrect_classif_persons_df = self.__append_classification__(_label, manualDfByNum, self.incorrect_classif_persons_df)
                        
                    if _label in yoloDfByNum['Label'].tolist():
                        mManualPolygon = self.__get_polygon__(manualDfByNum[manualDfByNum['Label'] == _label])
                        mYoloPolygon = self.__get_polygon__(yoloDfByNum[yoloDfByNum['Label'] == _label])
                        
                        mIntersection = mManualPolygon.intersection(mYoloPolygon).area / mManualPolygon.area
                        
                        if mIntersection > self.threshold:
                            self.classif_dict.loc[_label]['correct_classif'] += 1
                            self.correct_classif_persons_df = self.__append_classification__(_label, manualDfByNum[manualDfByNum["Label"] == _label], self.correct_classif_persons_df)
                        else:
                            self.incorrect_classif_persons_df = self.__append_classification__(_label, manualDfByNum, self.incorrect_classif_persons_df)
                            
    def fetchValue(self):
        cic = self.correct_classif_persons_df.iloc[1:]["filenames"].nunique()
        iic = self.incorrect_classif_persons_df.iloc[1:]['filenames'].nunique()
        clc = self.classif_dict["correct_classif"].sum()
        ilc = self.classif_dict["incorrect_classif"].sum()
        return cic, iic, clc, ilc