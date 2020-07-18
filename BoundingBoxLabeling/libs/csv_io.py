#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created 

@author: nihatompi
"""


from libs.constants import DEFAULT_ENCODING
import csv
import os

CSV_EXT = '.csv'
ENCODE_METHOD = DEFAULT_ENCODING

class CSVWriter:

    def __init__(self, imgName, imgSize, localImgPath = None):
        self.imgName = imgName
        self.imgSize = imgSize
        self.localImgPath = localImgPath
        self.boxlist = []
        self.verified = False
        
    def genCSV(self):
        """
            Return CSV header
        """
        header = [['filenames', 'x', 'y', 'Width', 'Height', 'Label']]
        return header
        
    def addBndBox(self, xmin, ymin, xmax, ymax, name, difficult):
        bndbox = {'xmin': xmin, 'ymin': ymin, 'xmax': xmax, 'ymax': ymax}
        bndbox['name'] = name
        bndbox['difficult'] = difficult
        self.boxlist.append(bndbox)

    def BndBox2CSVLine(self, box):
        x = box['xmin']
        y = box['ymin']
        width = abs(x - box['xmax']) + 1
        height = abs(y - box['ymax']) + 1
        boxName = box['name']        
        return x, y, width, height, boxName
    
    def save(self, targetFile=None):        
        out_file = None # Update yolo .csv
        isFilePresent = False
        lines = list()
        
        if os.path.exists(targetFile):
            # Read records from the file
            read_file  = open(targetFile, 'r')
            with read_file as csvfile:
                filereader = csv.DictReader(csvfile, delimiter = ',')
                for row in filereader:
                    if self.imgName != row["filenames"]:
                        lines.append([row["filenames"], row["x"], row["y"], row["Width"], row["Height"], row["Label"]])
            read_file.close()
            
            # Write to file
            out_file = open(targetFile, 'w')
        else:
            out_file = open(self.imgName + CSV_EXT, 'w')
            
            
        # Write data to the file
        with out_file as csvfile:
            filewriter = csv.writer(csvfile, delimiter = ',', 
                                        quotechar = '|', quoting = csv.QUOTE_MINIMAL)
            header = self.genCSV() # fetch header for CSV
            filewriter.writerow(header[0])
            filewriter.writerows(lines)
            
            for box in self.boxlist:
                x, y, width, height, boxName = self.BndBox2CSVLine(box)
                filewriter.writerow([self.imgName, x, y, width, height, boxName])
            
        out_file.close()   


class CSVReader:

    def __init__(self, filepath):
        # shapes type:
        # [labbel, [(x1,y1), (x2,y2), (x3,y3), (x4,y4)], color, color, difficult]
        self.shapes = {}
        self.filepath = filepath
        self.verified = False
        self.difficult = 0
        self.read()
        
    def setShape(self, filename, shape):
        shapeBag = []
        for s in shape:
            shapeBag.append((s["label"], s["points"], None, None, 0)) # shapeBag.append((s.get["label"], s.get["points"], None, None, 0))
        self.shapes.update({filename : shapeBag})
        
    def getShapes(self, filename):
        return self.shapes.get(filename)
        
    def fetchPoints(self, x, y, width, height):
        xmin = x
        ymin = y
        xmax = x + width - 1
        ymax = y + height - 1
        points = [(xmin, ymin), (xmax, ymin), (xmax, ymax), (xmin, ymax)]
        return points
        
    def read(self):
        read_file = open(self.filepath, 'r')
        
        with read_file as csvfile:
            filereader = csv.DictReader(csvfile, delimiter = ',')
            shapeBag = []
            i = 0
            for row in filereader:
                try:
                    if i == 0:
                        filename = row["filenames"] 
                    x = int(float(row["x"]))
                    y = int(float(row["y"]))
                    width = int(float(row["Width"]))
                    height = int(float(row["Height"]))
                    points = self.fetchPoints(x, y, width, height)
                    
                    if filename != row["filenames"]:
                        self.shapes[filename] = shapeBag
                        shapeBag = []                        
                        filename = row["filenames"]
                    
                    shapeBag.append((row["Label"], points, None, None, self.difficult))
                except:
                    print("X: %s, Y: %s, W: %s, H: %s, L: %s, FN: %s" %(row["x"], row["y"], row["Width"], row["Height"], row["Label"], row["filenames"]))                
                i += 1
            # Add the last shape bag if present
            if shapeBag != []:
                self.shapes[filename] = shapeBag
        read_file.close()