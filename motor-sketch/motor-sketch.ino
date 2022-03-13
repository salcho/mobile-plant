// 0-255 speed value
#define SPEED 33
// min number of samples needed before changing direction
#define MIN_SAMPLES 10

const int controlPin1 = 2;
const int controlPin2 = 10;
const int enablePin = 11;
const int onOffSwitchStateSwitchPin = 12;

int wasOn = 0;

int motorEnabled = 0;
int motorDirection = 1;

int baseLeft;
int baseRight;

enum direction{ LEFT, RIGHT};

int samples = 0;
enum direction lastSource = 0;

void setup() {
  Serial.begin(9600);
  pinMode(onOffSwitchStateSwitchPin, INPUT);
  
  pinMode(controlPin1, OUTPUT);
  pinMode(controlPin2, OUTPUT);
  pinMode(enablePin, OUTPUT);
  pinMode(13, OUTPUT);
  
  digitalWrite(enablePin,LOW);

  baseLeft = analogRead(A0);
  delay(5);
  baseRight = analogRead(A1);
}

void loop() {
  int left = abs(baseLeft - analogRead(A0));
  delay(5);
  int right = abs(baseRight - analogRead(A1));

  // check if the light source has changed consistently over the last n measurements
  // if so, change motor direction
  int motorDirection;
  enum direction source = left > right ? LEFT : RIGHT;
  if (lastSource != source) {
    Serial.println(samples);
    // we've seen a consistent change in direction
    if (samples > MIN_SAMPLES) {
      motorDirection = source == LEFT ? HIGH : LOW;
      lastSource = source;
      samples = 0;
    // need to collect more samples
    } else {
      samples++;
    }
  }

  
  int isOn = digitalRead(onOffSwitchStateSwitchPin);
  if(isOn != wasOn && isOn == HIGH){
      motorEnabled = !motorEnabled;
  }

  delay(10);
  if (motorDirection == 1){
    digitalWrite(controlPin1, HIGH);
    digitalWrite(controlPin2, LOW);
  }
  else {
    digitalWrite(controlPin1, LOW);
    digitalWrite(controlPin2, HIGH);
  }

  if (motorEnabled == 1) {
    digitalWrite(13, HIGH);
    analogWrite(enablePin, SPEED);
  }
  else {
    digitalWrite(13, LOW);
    analogWrite(enablePin, 0);
  }

  wasOn = isOn;
}
