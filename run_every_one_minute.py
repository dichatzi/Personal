import time
import datetime


while True:
  # Wait until the begining of each minute
  time.sleep(60 - time.time() % 60)

  # Start program
  print(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

  start_time = time.time()
  time.sleep(5)
  end_time = time.time()
  print(end_time - start_time)
