# LabSensE Potentiostat

## Introduction

The LabSensE Potentiostat was developed for use in research and applications to be conducted in the research group. This repository contains the code for an interface capable of communicating with and controlling the potentiostat, as well as the firmware for the microcontroller.

## LabSensE Potentiostat App

This repository includes the code for building the app, which was developed using Flutter for experimental planning and conducting measurements. The app currently supports the following functions listed below:

- Connection with the Arduino module via Bluetooth for experiments
- Experimental planning, including each stage of the experiment, along with additional information such as title, description, and dates
- Conducting measurements, with the possibility of real-time data visualization graphically
- Viewing previous measurements, with the ability to export data to a CSV or txt file
- Viewing results of previous measurements
- Calibration of the potentiostat (to be implemented)

> **Note:** The app is open-source and can be modified to meet specific user needs or applications.

### Supported Platforms

The app was developed using the Flutter framework, allowing compilation for both Android and iOS platforms. Currently, the app is configured to work only on Android devices, but with minor modifications, it can be compiled for iOS devices.

Platforms such as Windows, Linux, and MacOS are not supported; however, with additional development, the app can be adapted for these platforms. The current limitation is Bluetooth communication, as the package used for Bluetooth communication is specific to Android and iOS.

### Installation

The app can be installed on Android devices through the Play Store. The download link will be provided in the future. It is also possible to compile the app from the source code in this repository. An APK file for installing the app on Android devices will be available in the *Releases* section.

> To compile the app, you need to have Flutter installed on your machine. To install Flutter, follow the instructions in the [official documentation](https://flutter.dev/docs/get-started/install).

### Usage

To use the app, the Arduino module must be connected to the Android device via Bluetooth and the firmware on the module must be loaded. After connecting the Arduino module to the Android device, open the app and click the potentiostat icon to establish the connection.

Once connected, you can create templates or experiments to be performed by the LabSensE Potentiostat.

1. **Templates:** These are experiment stages that can be reused in various experiments. The app provides some default templates, but you can create new ones to meet your needs. Currently, cyclic voltammetries with configurable potential window, number of cycles, and scan rate are supported.

2. **Experiments:** These are experiments composed of one or more stages. Each experiment can be executed by the potentiostat, and the results will be stored within the app. Results can be viewed in real-time or later.

When conducting a measurement, you need to provide a title and a brief description. After starting, each stage will send commands to the Arduino module, and the measurement will be performed. At the end of the experiment, the data will be stored in the app and can be exported to a CSV or txt file. You can follow the experiment stages and visualize the data in real-time.

## Hardware

The potentiostat hardware consists of an Arduino microcontroller and a board with the circuit proposed in the work titled [*Building a Microcontroller Based Potentiostat: An Inexpensive and Versatile Platform for Teaching Electrochemistry and Instrumentation*](https://doi.org/10.1021/acs.jchemed.5b00961) by Gabriel N. Meloni.

Minor modifications were necessary for our application. Details of these changes will be provided in a document to be attached here in the future.

## Additional Information

### Contributions

Contributions are welcome. If you wish to contribute to the project, feel free to open an issue or a pull request.

### License

This project is licensed under the MIT license. For more information, see the [LICENSE](LICENSE.md) file.

### Authorship

- App: [Vicente Kalinoski Parmigiani](https://linktr.ee/vicenteparmi)
- Firmware: Gabriel N. Meloni, modified by [Vicente Kalinoski Parmigiani](https://linktr.ee/vicenteparmi)
- Hardware: Gabriel N. Meloni

This project was developed at the Laboratory of Sensors and Electrochemistry (LabSensE) at the Federal University of Paraná (UFPR), under the guidance of professors Dr. Marcio Fernando Bergamini and Dr. Luiz Humberto Marcolino Junior.

Special thanks to Dr. Maurício Papi for his significant support and guidance, which was fundamental to the development of this project.
