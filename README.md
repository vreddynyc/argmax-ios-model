# Argmax Coding Challenge
## iOS Face Detection model
## Vijay Reddy

Project that detects faces using on-device model on iOS.  Used SwiftUI 5 and targets iOS 16+

Project Instructions
- Download project zip file directly or clone from https://github.com/vreddynyc/argmax-ios-model.git
- Open project
- Download the Face Detection model (YOLOv3Int8LUT.mlmodel) in the YOLOv3 section (bottom of page) at
  https://developer.apple.com/machine-learning/models/
- Copy Face Detection model into the project folder, and delete the old reference
- Run project on any device running iOS 16+

Runtime Instructions
- Upon running the app, a list of Stack Overflow Users will show
- Each list item will show a user name and profile image
- Below the profile image, a green text will read "Face Detected" if the on-device model detects a faces
- Click on the profile image to see details
- The details page will show the objects detected with labels and respective confidence
- A "Face Detected" profile image will have an object with a "person" label and a confidence of at least 95%

Third-Party Libraries
- Used Kingfisher to display images. Also provides a callback to run model analysis on successful image load
