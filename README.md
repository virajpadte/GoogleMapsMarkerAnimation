# GoogleMapsMarkerAnimation
[![forthebadge](http://forthebadge.com/images/badges/made-with-swift.svg)](http://forthebadge.com) [![forthebadge](http://forthebadge.com/images/badges/built-with-love.svg)](http://forthebadge.com)

Moving markers like UBER on google maps in a swift application.

The locations information is stored in dataHeading.csv file.

##### Steps to be performed before running building the application:

* Use the Podfile to install project dependencies.
* Generate a new api key for the Google Maps API. Add apiKey in the sample_config.plist.
* Replace path is app delegate to point to the sample_config.plist.
* Generate a dataHeading.csv file by following this procedure:
   * Add the route you want to generate data for on a new map which can be created on the https://mymaps.google.com portal.
   * Export a route layer using to a kml file.
   * Upload the generated route kml file to http://www.gpsvisualizer.com/convert_input.
   * Set the output file format to plain text and set the "plain text delimiter" option to comma and leave all the remaining options to default to generate the required comma separated file.


##### More additional details for algorithm frenzies out there:
I refereed http://www.igismap.com/formula-to-find-bearing-or-heading-angle-between-two-points-latitude-longitude/ for understanding heading calculating. For some developers (including myself), following a bunch of formulas on a blog might get very confusing. So I created a simple excel sheet for understanding the calculation before you move on to understand the code implementation.


##### Keep contributing to Open Source
लोकाः समस्ताः सुखिनोभवंतु