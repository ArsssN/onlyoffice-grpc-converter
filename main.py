import logging
import sys
import os

# Add generated/ to Python import path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "generated")))
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "generated/google/api/")))

from service.onlyoffice_service import serve as onlyoffice_serve
# from service.another_service import serve as another_serve  # Example if you add more services

def main():
    logging.basicConfig(level=logging.INFO)
    logging.info("Starting all gRPC services...")

    # Here you can start multiple services if you want, or just one
    onlyoffice_serve()

    # For multiple services, consider threading or asyncio to run them concurrently

if __name__ == "__main__":
    main()
