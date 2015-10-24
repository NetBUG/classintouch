import sys
import logging, sys
logging.basicConfig(stream=sys.stderr)

sys.path.insert(0, '/w/classintouch/backend')
from app import create_app, app
application = create_app()