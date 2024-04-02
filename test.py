from datetime import datetime
import threading

def outcome():
    threading.Timer(2.0, outcome).start()
    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    print("Current Time =", current_time)
    user_input = input("Press 'q' to quit or any other key to continue: ")
    if user_input.lower() == 'q':
        print("Exiting program.")
        return

outcome()
