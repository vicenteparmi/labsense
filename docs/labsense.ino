#include <Wire.h>
#include <Vector.h>
#define DEBUG 1

// Library for virtual serial ports over normal pins
#include <SoftwareSerial.h>
SoftwareSerial bluetooth(7, 8); // RX, TX
bool doUpdateStatus = false;

// Debug mode
bool DEBUGMODE = true;

// Bluetooth communication between Arduino and Android
const char START_BYTE = '$';
const char END_BYTE = '#';
String data = "";

// Ports
int a = 10; // Pin for controlling the potentiostat
float ct = A0; // Pin for current measurement (ADC)
int soundPort = 5; // Pin for sound output

// Variables for the potentiostat
int val = 0; // Variable for storing the analog value
float c = 0; // Variable for storing the current value
int n = 0; // Counter variable
float Potstep = 0.0078; // Step size for the potentiostat (fixed due to the DAC resolution)
int resistor = 12E3; // Resistor value for current measurement
double current = 0; // Variable for storing the current value

// Variables for the scan rates
int vevals[] = {}; // Array of multiple scan rates values (mV/s)
int count = 1; // Number of scan rates
long *intervalos = (long*) malloc(sizeof(long) * count);
int cycle_count = 0; // Number of cycles
float min_voltage = 0; // Minimum voltage
float max_voltage = 0; // Maximum voltage
float start_voltage = 0; // Start voltage
bool enable_sound = false; // Enable sound
bool sweep_direction = true; // Sweep direction (true = forward, false = reverse)

void setup() {
	TCCR1B = TCCR1B & B11111000 | B00000001; //Set dividers to change PWM frequency
	
    // Start the serial communication
    Serial.begin(9600);
    bluetooth.begin(9600);

    // Print the initial message
    Serial.println("Arduino is ready");

	pinMode(a,OUTPUT);
	pinMode(ct,INPUT);
}

void loop() {
    if (bluetooth.available() > 0) {

        char RECIEVED = bluetooth.read();

        if (RECIEVED == START_BYTE) {
            Serial.print("Recording data... ");
            doUpdateStatus = true;
        } else if (RECIEVED == END_BYTE) {
            Serial.println("Data received!");
            Serial.println(data);
            doUpdateStatus = false;
            interpretData(data);
            data = "";
        } else if (doUpdateStatus) {
            data += RECIEVED;
        }
    }
}

void interpretData(String data) {
        if (data[0] == '1') { // Record the procedure data
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
                for (int i = 2; i < data.length(); i++) {
                    if (data[i] == '!') {
                        partIndex++;
                    } else {
                        dataParts[partIndex] += data[i];
                    }
                }

                // Get the procedure data
                int cycleCount = dataParts[0].toInt();
                float minVoltage = dataParts[1].toFloat();
                float maxVoltage = dataParts[2].toFloat();
                float startVoltage = dataParts[3].toFloat();
                bool enableSound = dataParts[4] == "1";
                float scanRate = dataParts[5].toFloat();
                bool sweepDirection = dataParts[6] == "1";

                // Print the procedure data
                if (DEBUGMODE) {
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
                }

                // Save the procedure data
                cycle_count = cycleCount;
                min_voltage = minVoltage;
                max_voltage = maxVoltage;
                start_voltage = startVoltage;
                enable_sound = enableSound;
                vevals[count] = scanRate;
                sweep_direction = sweepDirection;

                // Calculate the intervals
                for (int i = 0; i < count; i++) {
                    intervalos[i] = (1000000L / (vevals[i] * 128L));
                }
            } else if (data[0] == '2') {
                // Start the experiment
                // The data is in the format:
                // [2]
                // Example: 2
                // This means that the experiment will start

                // Print the start message
                bluetooth.println("$2#");
                Serial.println("Starting the experiment");
            
                // Start the experiment
                runExperiment();
            } else {
                // Invalid data
                Serial.println("Invalid data");
            }

        
    }

void runExperiment() {
      // Print title
  Serial.println("\n---------------------------------------------");

	for(int pos = 0; pos < count; pos++){
	intervalos[pos]=(1000000L/((vevals[pos])*128L));
	}

	playSound(2, 2000);
	delay(1000);
	
	for(int pos = 0; pos < count; pos++) {
		n = 0;
		while(n <= (cycle_count-1)){
			
      // Print header
      Serial.println("\n---------------------------------------------");
      Serial.println("Value;Current;Cycle;Scan_Rate;Interval");

      // Pack the data and send it to the Android app
      String pack = "";

      //Start the forward scan
			for(val = 0; val <= 255; val++){
				analogWrite(a,val);
				Serial.print(val);
				delay(intervalos[pos]);
				//c = ((0.00195*(analogRead(ct))-1)*1000); // Current reading outputs in uA!!!
				c =analogRead(ct);
				Serial.print(";");
				Serial.print(c);
				Serial.print(";");
				Serial.print(n);
				Serial.print(";");
				Serial.print(vevals[pos]);
				Serial.print(";");
				Serial.print(intervalos[pos]);
				Serial.print(";");
				Serial.print((float)val/255*2-1, 3);
				Serial.print(";");

				current = (double)c/1023*5/resistor;
				Serial.println(current, 10);

                // Add the data to the pack
                pack += String(val) + ";" + String(c)+ "\n";

                // Send the data to the Android app every 10 cycles
                if (n % 20 == 0) {
                    bluetooth.println(pack);
                    pack = "";
                }
            }

            // Send the remaining data to the Android app
            bluetooth.println(pack);
            pack = "";

			//Start the reverse scan
			for(val = 255; val >= 0; val--){
				analogWrite(a,val);
				Serial.print(val);
				delay(intervalos[pos]);
				//c = ((0.00195*(analogRead(ct))-1)*1000); // Current reading outputs in uA!!!
				
				c =analogRead(ct);
				Serial.print(";");
				Serial.print(c);
				Serial.print(";");
				Serial.print(n);
				Serial.print(";");
				Serial.print(vevals[pos]);
				Serial.print(";");
				Serial.print(intervalos[pos]);
				Serial.print(";");
				Serial.print((float)val/255*2-1, 3);
				Serial.print(";");
				
				current = (double)c/1023*5/resistor;
				Serial.println(current, 10);

                // Add the data to the pack
                pack += String(val) + ";" + String(c)+ "\n";

                // Send the data to the Android app every 10 cycles
                if (n % 20 == 0) {
                    bluetooth.println(pack);
                    pack = "";
                }
            }
            
            // Send the remaining data to the Android app
            bluetooth.println(pack);
            pack = "";
			
			n=n+1;
		}
	}

  // Play sound at the end of the program
  delay(2000);
  playSound(2, 2000);

  // Print "done" at the end of the program
  bluetooth.print("END");
  delay(20000);
}

void playSound(int count, int frequency) {
	if(enable_sound){
		for (int i = 0; i < count; i++) {
			tone(soundPort, frequency, 20);
			delay(20);
			noTone(soundPort);
			delay(50);
		}
	}
}