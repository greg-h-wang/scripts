  1 #!/usr/bin/env python
  2 import time
  3 import sys
  4 from zkApi import TzKazooClient
  5
  6 zkCli = TzKazooClient(servers=[sys.argv[1]])
  7 zkCli.push(sys.argv[2], top_path=sys.argv[3])
  8 zkCli.stop()
  9 time.sleep(3)
 10 zkCli.close()
