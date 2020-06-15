import numpy as np
import os
# import six.moves.urllib as urllib
import sys
import tensorflow as tf
import os
import pathlib

from collections import defaultdict
from io import StringIO
# from matplotlib import pyplot as plt
from PIL import Image
# from IPython.display import display
from urllib.request import urlopen
from datetime import datetime

model = None
model_name = 'model'
model_dir = pathlib.Path(model_name)

# List of the strings that is used to add correct label for each box.
labels_filename = os.path.join(model_dir, "labels.txt")
labels = []

def initialize(model_dir = model_dir, labels_filename = labels_filename):
    #TODO - modify to take tf json
    global model, labels

    model = tf.saved_model.load(str(model_dir))
    model = model.signatures['serving_default']

    with open(labels_filename, 'rt') as lf:
        labels = [*["bg"],*[l.strip() for l in lf.readlines()]]

    return model


def predict_image(image):
    global model
    image = np.asarray(image)
    # The input needs to be a tensor, convert it using `tf.convert_to_tensor`.
    input_tensor = tf.convert_to_tensor(image)
    # The model expects a batch of images, so add an axis with `tf.newaxis`.
    input_tensor = input_tensor[tf.newaxis,...]

    # Run inference
    results = model(input_tensor)
    num_detections = int(results.pop('num_detections'))

    convert_to_list = lambda x: list(x) if isinstance(x, np.ndarray) else float(x)

    converted_results = [{k:convert_to_list(v[0, i].numpy()) for k,v in results.items()} for i in range(num_detections)]
    for i in converted_results:
        i['class'] = labels[int(i['detection_classes'])]
    return converted_results


def log_msg(msg):
    print("{}: {}".format(datetime.now(),msg))

def predict_url(imageUrl):
    log_msg("Predicting from url: " +imageUrl)
    with urlopen(imageUrl) as testImage:
        image = Image.open(testImage)
        return predict_image(image)

def convert_to_nparray(image):
    # RGB -> BGR
    log_msg("Convert to numpy array")
    image = np.array(image)
    return image[:, :, (2,1,0)]

def update_orientation(image):
    exif_orientation_tag = 0x0112
    if hasattr(image, '_getexif'):
        exif = image._getexif()
        if exif != None and exif_orientation_tag in exif:
            orientation = exif.get(exif_orientation_tag, 1)
            log_msg('Image has EXIF Orientation: ' + str(orientation))
            # orientation is 1 based, shift to zero based and flip/transpose based on 0-based values
            orientation -= 1
            if orientation >= 4:
                image = image.transpose(Image.TRANSPOSE)
            if orientation == 2 or orientation == 3 or orientation == 6 or orientation == 7:
                image = image.transpose(Image.FLIP_TOP_BOTTOM)
            if orientation == 1 or orientation == 2 or orientation == 5 or orientation == 6:
                image = image.transpose(Image.FLIP_LEFT_RIGHT)
    return image
