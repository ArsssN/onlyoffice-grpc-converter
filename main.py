import logging
import sys
import os

# Add project root to Python path
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

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
