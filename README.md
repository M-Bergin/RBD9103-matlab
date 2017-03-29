# RBD9103-matlab

MATLAB script to open serial port with RBD 9103 picoammeter.

To use, first run read_detector_rbd9103('init',n) to initialise the detector and clear any data filters where n is the sampling period you wish to use in ms (15 is the fastest). Then the function can be called using read_detector_rbd9103(M) to return the average current recorded after M samples are taken.

The range of the ammeter is set within the intialisation and needs to be edited in the m file directly.

The intialisation steps are removed from the actual reading from the ammeter to try and making the reading process as fast as possible.
