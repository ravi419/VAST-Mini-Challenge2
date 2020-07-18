#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created

@author: nihatompi
"""


import pandas as pd

class CSVReaderDF:

    def __init__(self, filepath):
        self.filepath = filepath
        self.__read__()
        
    def deleteRecord(self, filename, shapes):
        if filename is not None and shapes is not None:
            fn = filename.split("_")
            self.dataFrame = self.dataFrame[(self.dataFrame["filenames"] != fn[0]) & (self.dataFrame["num"] != int(float(fn[1])))]
            for shape in shapes:
                label = shape['label']
                bndbox = self.__convertPoints2BndBox__(shape['points'])
                x, y, width, height = self.__BndBox2Value__(bndbox)
                new_row = {'filenames':fn[0], 'num':int(fn[1]), 'x':x, 'y':y, 'Width':width, 'Height':height, 'Label':label}
                self.dataFrame = self.dataFrame.append(new_row, ignore_index=True)
        
    def getDataFrame(self):
        return self.dataFrame
        
    def __read__(self):
        df = pd.read_csv(self.filepath)
        self.dataFrame = self.__remove_invalid_data__(df)
        
    def __remove_invalid_data__(self, dataFrame):
        dataFrame["Width"] = dataFrame["Width"].apply(lambda x: int(x) if str(x).isdigit() else None)
        dataFrame["Height"] = dataFrame["Height"].apply(lambda x: int(x) if str(x).isdigit() else None)
        dataFrame["x"] = dataFrame["x"].apply(lambda x: int(x) if str(x).isdigit() else None)
        dataFrame["y"] = dataFrame["y"].apply(lambda x: int(x) if str(x).isdigit() else None)        
        return dataFrame.dropna()
    
    def __convertPoints2BndBox__(self, points):
        xmin = float('inf')
        ymin = float('inf')
        xmax = float('-inf')
        ymax = float('-inf')
        for p in points:
            x = p[0]
            y = p[1]
            xmin = min(x, xmin)
            ymin = min(y, ymin)
            xmax = max(x, xmax)
            ymax = max(y, ymax)

        if xmin < 1:
            xmin = 1

        if ymin < 1:
            ymin = 1

        return (int(xmin), int(ymin), int(xmax), int(ymax))
    
    def __BndBox2Value__(self, box):
        x = box[0]
        y = box[1]
        width = abs(x - box[2]) + 1
        height = abs(y - box[3]) + 1       
        return x, y, width, height