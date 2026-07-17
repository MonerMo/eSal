from gpiozero import LED , Buzzer
from time import sleep
from config import RED_LED_PIN , GREEN_LED_PIN

red_led = LED(RED_LED_PIN)
green_led = LED(GREEN_LED_PIN)


