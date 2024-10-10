# Autocross GPS Mapping App

This project is an iOS application that allows users to map an autocross course by tagging cones using GPS coordinates. The app is designed for use during autocross events and allows users to tag different types of cones on a map, including pointer cones, starting cones, and single cones. The app also supports the use of external GPS devices, such as the Garmin GLO 2, for improved location accuracy.

## Features

- **Tagging Cones**: Users can tag various types of cones at their current GPS location, including:
  - **Starting cones**: Automatically tagged as the first two cones in the course.
  - **Pointer cones**: Cones that can be rotated to indicate direction.
  - **Single cones**: Regular cones placed at the current location.
  
- **Real-time GPS Accuracy Monitoring**: Displays GPS accuracy in meters and adjusts based on device and environmental conditions.
  
- **Cone Placement at Current Location**: All cones (including pointer cones) are placed at the user’s current GPS location with no offset, allowing for precise course mapping.
  
- **Pointer Cone Rotation**: Pointer cones can be rotated to indicate direction and can be modified even after being tagged.

- **Course Saving**: Users can save their tagged course, including cone locations and rotations, to view or edit later.

- **Zoom and World Rotation**: The map view supports zooming and world rotation to provide better visualization of the course.

- **External GPS Device Support**: Works with external GPS devices, such as the Garmin GLO 2, for enhanced GPS accuracy when mapping the course.

## Requirements

- **iOS 14.0+**
- **Xcode 12+**
- **Swift 5.0+**
- **Garmin GLO 2 (Optional)**: For better GPS accuracy during course mapping.

## Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/yourusername/autocross-gps-mapper.git
    cd autocross-gps-mapper
    ```

2. Open the project in Xcode:

    ```bash
    open autocross-mapper.xcodeproj
    ```

3. Install necessary dependencies:
   - Ensure you have an active developer account.
   - Set up your **Core Location** permissions under **Capabilities**.

4. Build and run the app on your iOS device:
   - You’ll need to run the app on a real device (iPhone or iPad) for GPS functionality.
   - Ensure Bluetooth is enabled if using an external GPS device like the **Garmin GLO 2**.

## Usage

### Main Features:

1. **Tagging Cones**:
   - Start by selecting a cone type (single, pointer) from the buttons.
   - Tag cones by pressing the **Tag Cone** button, and they will be placed at your current GPS location.
   - Pointer cones will have a small rectangle (dash) indicating direction. You can rotate these cones after placing them using the **Rotate Pointer Cone** slider.

2. **View and Edit Saved Courses**:
   - After tagging your cones, you can save the course by pressing the **Save** button. The course will be saved with a timestamp.
   - View saved charts in the **Saved Charts** section.

3. **GPS Accuracy**:
   - The GPS status and accuracy are shown in the top bar, indicating whether your GPS accuracy is sufficient for tagging cones. The default threshold can be adjusted using the slider.
   - For improved accuracy, use an external GPS device like the **Garmin GLO 2**.

4. **Using External GPS (Garmin GLO 2)**:
   - Pair the **Garmin GLO 2** via Bluetooth.
   - Use a third-party app (such as Garmin Pilot) to relay GPS data to your iPhone.
   - Once connected, the app will automatically use the Garmin GPS data for cone tagging.

### Zoom and Rotation:
- Use the **Zoom Level** slider to zoom in or out on the map.
- Rotate the entire world map using the **Rotate World** slider.

### Saving the Course:
- Tap the **Save** button to store your current course layout.
- The saved course will include the cone types, locations, and pointer cone directions.

### Viewing Saved Charts:
- You can view saved charts from the **Saved Charts** section and rotate or zoom the saved course map.

## External GPS Device Integration

To use an external GPS device like the **Garmin GLO 2**:

1. Pair the device with your iPhone via Bluetooth.
2. Install and launch a third-party app like **Garmin Pilot** to manage the external GPS data.
3. The iPhone will use the Garmin GLO 2’s GPS data for all location services, including cone tagging within the app.


## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.
