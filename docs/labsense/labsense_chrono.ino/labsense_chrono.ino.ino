#include <Wire.h>
#include <Vector.h>
#define DEBUG 1

// Library for virtual serial ports over normal pins
// #include <SoftwareSerial.h>
// SoftwareSerial bluetooth(7, 8); // RX, TX
// bool doUpdateStatus = false;

// Debug mode
bool DEBUGMODE = true;

// Bluetooth communication between Arduino and Android
const char START_BYTE = '$';
const char END_BYTE = '#';
String data = "";

// Ports
int a = 10;        // Pin for controlling the potentiostat
float ct = A0;     // Pin for current measurement (ADC)
int soundPort = 5; // Pin for sound output

// Variables for the potentiostat
int val = 0;            // Variable for storing the analog value
int c = 0;              // Variable for storing the current value
int n = 0;              // Counter variable
float Potstep = 0.0078; // Step size for the potentiostat (fixed due to the DAC resolution)
int resistor = 12E3;    // Resistor value for current measurement
double current = 0;     // Variable for storing the current value

// Variables for the scan rates
int count = 1;               // Number of scan rates
int cycle_count = 0;         // Number of cycles
float min_voltage = 0;       // Minimum voltage
float max_voltage = 0;       // Maximum voltage
float start_voltage = 0;     // Start voltage
float scan_rate = 0;         // Scan rate
float interval = 0;         // Interval
bool enable_sound = false;   // Enable sound
bool sweep_direction = true; // Sweep direction (true = forward, false = reverse)

void setup()
{
    TCCR1B = TCCR1B & B11111000 | B00000001; // Set dividers to change PWM frequency

    // Start the serial communication
    Serial.begin(9600);
    // bluetooth.begin(9600);

    // Print the initial message
    Serial.println("Arduino is ready");

    pinMode(a, OUTPUT);
    pinMode(ct, INPUT);

    runChronoExperiment();
}

void loop()
{
    // if (bluetooth.available() > 0)
    // {

    //     char RECIEVED = bluetooth.read();

    //     if (RECIEVED == START_BYTE)
    //     {
    //         Serial.print("Recording data... ");
    //         playSound(1, 1000);
    //         doUpdateStatus = true;
    //     }
    //     else if (RECIEVED == END_BYTE)
    //     {
    //         Serial.println("Data received!");
    //         Serial.println(data);
    //         playSound(1, 3000);
    //         doUpdateStatus = false;
    //         interpretData(data);
    //         data = "";
    //     }
    //     else if (doUpdateStatus)
    //     {
    //         data += RECIEVED;
    //     }
    // }
}

void interpretData(String data)
{
    if (data[0] == '1')
    { // Record the procedure data
        // Record the procedure data
        // The data is in the format:
        // [1][cycle_count][min_voltage][max_voltage][start_voltage]
        // [enable_sound][scan_rate][sweep_direction]
        // Example: 1!3!-1!1!0!1!100
        // This means that the procedure will have 3 cycles, the minimum voltage is -1V,
        // the maximum voltage is 1V, the start voltage is 0V, the sound is enabled,
        // the scan rate is 100 mV/s and the sweep direction is foward

        // Split the data by the '!' character into a array of strings
        String dataParts[20]; // Maximum of 20 parts, minimum of 6 parts
        int partIndex = 0;
        for (int i = 2; i < data.length(); i++)
        {
            if (data[i] == '!')
            {
                partIndex++;
            }
            else
            {
                dataParts[partIndex] += data[i];
            }
        }

        // Get the procedure data
        int cycleCount = dataParts[0].toInt();
        float minVoltage = dataParts[1].toFloat();
        float maxVoltage = dataParts[2].toFloat();
        float startVoltage = dataParts[3].toFloat();
        bool enableSound = dataParts[4] == "1";
        float scanRate = dataParts[5].toFloat() * 1000;
        bool sweepDirection = dataParts[6] == "1";

        // Calculate the intervals
        interval = (1000000L / (scanRate * 128L));

        // Print the procedure data
        if (DEBUGMODE)
        {
            Serial.print("Cycle count: ");
            Serial.println(cycleCount);
            Serial.print("Min voltage: ");
            Serial.println(minVoltage);
            Serial.print("Max voltage: ");
            Serial.println(maxVoltage);
            Serial.print("Start voltage: ");
            Serial.println(startVoltage);
            Serial.print("Enable sound: ");
            Serial.println(enableSound);
            Serial.print("Scan rate: ");
            Serial.println(scanRate);
            Serial.print("Sweep direction: ");
            Serial.println(sweepDirection);
            Serial.print("Interval: ");
            Serial.println(interval);
        }

        // Save the procedure data
        cycle_count = cycleCount;
        min_voltage = minVoltage;
        max_voltage = maxVoltage;
        start_voltage = startVoltage;
        enable_sound = enableSound;
        scan_rate = scanRate;
        sweep_direction = sweepDirection;

    }
    else if (data[0] == '2')
    {
        // Start the cyclic voltaammetry experiment
        // The data is in the format:
        // [2]
        // Example: 2
        // This means that the experiment will start

        // Print the start message
        // bluetooth.println("$2#");
        Serial.println("Starting the experiment: cyclic voltammetry");

        // Wait for 5 seconds
        delay(5000);

        // Start the experiment
        runExperiment();
    }
    else if (data[0] == '3')
    {
        // Start the chronoamprometry experiment
        // The data is in the format:
        // [3]
        // Example: 3
        // This means that the experiment will start

        // Print message
        Serial.println("Starting the experiment: chronoamprometry");

        // Wait for 5 seconds
        delay(5000);

        // Start the experiment
        runChronoExperiment();
    }
    else
    {
        // Invalid data
        Serial.println("Invalid data");
    }
}

void runExperiment()
{
    // Print title
    Serial.println("\n---------------------------------------------");

    playSound(2, 2000);
    delay(1000);

    // Obtain the max and min voltage, as well as the start voltage
    // The voltage is recieved in the range of -1 to 1, so we need to convert it to the range of 0 to 255
    const float max_voltage_run = (max_voltage + 1) * 127;
    const float min_voltage_run = (min_voltage + 1) * 127;
    const float start_voltage_run = (start_voltage + 1) * 127;

    static bool foward = sweep_direction;

    while (n <= (cycle_count - 1) * 2) // The number of cycles is multiplied by 2 because there are two scans per cycle, forward and reverse
    {
        // Buffer
        char buffer[16];

        // Print header
        Serial.println("\n---------------------------------------------");
        Serial.println("Value;Current;Cycle;Scan_Rate;Interval");

        // Start the forward scan if the sweep direction is true
        if (foward) {

            // If is the first start on the start voltage, else start on the min voltage
            static int start = 0;
            if (n == 0) {
                start = start_voltage_run;
            } else {
                start = min_voltage_run;
            }

            for (val = start; val <= max_voltage_run; val++)
            {
                analogWrite(a, val);
                Serial.print(val);
                delay(interval);
                c = analogRead(ct);
                Serial.print(";");
                Serial.print(c);

                // Send the data to the Android app
                // snprintf(buffer, sizeof(buffer), "%d;%d\n", val, c);
                // bluetooth.write(buffer);
            }
        } else { // Start the reverse scan if the sweep direction is false
            
            // If is the first start on the start voltage, else start on the max voltage
            static int start = 0;
            if (n == 0) {
                start = start_voltage_run;
            } else {
                start = max_voltage_run;
            }

            for (val = start; val >= min_voltage_run; val--)
            {
                analogWrite(a, val);
                Serial.print(val);
                delay(interval);
                c = analogRead(ct);
                Serial.print(";");
                Serial.print(c);

                // Send the data to the Android app
                // snprintf(buffer, sizeof(buffer), "%d;%d\n", val, c);
                // bluetooth.write(buffer);
            }
        }

        // Change the direction
        foward = !foward;
        n += 1;
    }

    // Play sound at the end of the program
    delay(2000);
    playSound(2, 2000);

    // Print "done" at the end of the program
    // bluetooth.write("E");
}

void runChronoExperiment()
{
    // Print title
    Serial.println("\n------------------ STARTING -------------------");

    playSound(2, 2000);
    delay(5000);

    // In this experiment, the data saved is used as:
    // [total_duration (s)][not used][not used][apply_voltage (V)]
    // [enable_sound][measurement_interval (s)][not used]
    // Example: 100!0!0!1!1!0.1!0
    // This means that the total duration is 100s, the applied voltage is 1V,
    // the sound is enabled, the measurement interval is 0.1s

    // Execute the chronoamperometry experiment
    int step = 0;
    const float duration = 2000; // The duration is in seconds
    const float measurement_interval = 0.1 / 1000; // Use scan rate as the measurement interval
    const float number_of_points = duration / measurement_interval;

    // Buffer
    char buffer[16];

    // Apply the voltage
    // The voltage is recieved in the range of -1 to 1, so we need to convert it to the range of 0 to 255
    const int apply_voltage = (int)((0.8 + 1) * 127); // Apply the start voltage
    analogWrite(a, apply_voltage);
    
    while (step < number_of_points) {

        // Record the data
        Serial.print(step);
        delay(measurement_interval * 1000);
        c = analogRead(ct);
        Serial.print(";");
        Serial.println(c);

        // Send the data to the Android app
        // snprintf(buffer, sizeof(buffer), "%d;%d\n", step, c);
        // bluetooth.write(buffer);

        // Increment the step
        step++;
    }

    // Play sound at the end of the program
    delay(2000);
    playSound(2, 2000);

    // Print "done" at the end of the program
    // bluetooth.write("E");

    // Print the end message
    Serial.println("Chronoamperometry experiment done");
    delay(5000);
}

void playSound(int count, int frequency)
{
    if (enable_sound)
    {
        for (int i = 0; i < count; i++)
        {
            tone(soundPort, frequency, 20);
            delay(20);
            noTone(soundPort);
            delay(50);
        }
    }
}