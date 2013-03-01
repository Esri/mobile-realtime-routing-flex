# Flex Mobile Routing app - Changelog

## v0.3.0 (Feb 2013)
- Many UX optimizations

## Fixes in v0.2.1 (August 2012):
- added skinClass to route directions to and from fields. This fixed a bug when you dragged the container
- the to and from text fields wouldn't move until you released the container.

## Fixes in V0.2:
- Updated to work with ArcGIS API for Flex v3
- Updated to work with Adobe Flex SDK v4.6
- Fixed minor issues related to the upgrade.
- Replaced Locator so that it now uses single line input.
- Fixed issue where Geolocation would continue to run after user hit "Stop Tracking".
- Fixed setRequestedUpdateInterval() bug.
- Added a basic algorithm to reduce wild GPS fluctuations during times of low accuracy.  

## Known Issues in V0.1:
- Only the GPS works in off-line (no internet) mode. The maps don't work off-line since they currently
  need an internet connection.
- setRequestedUpdateInterval() doesn't change when speed is above SPEED_THRESHOLD (GeolocationController.as)
- Some minor icon distortion when deployed to iPhone.
- Not currently configured to return segment times and miles in the route results.
- Location service configured to work in the U.S. Only.
- GPS Heading property doesn't currently work in Flex v4.5.1 with Android.
- NativeApplication.nativeApplication.exit() doesn't work on iPhone. This is an iOS limitation! 
- Currently configured in MobileMap-app.xml to NOT allow auto-orientation. This is simply because of styling
  issues in landscape mode that I wasn't able to address before releasing the app.