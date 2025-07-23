from concurrent import futures
import grpc
from generated import onlyoffice_pb2, onlyoffice_pb2_grpc
from lib.onlyoffice_converter import convert_with_onlyoffice

class OnlyOfficeConverterServicer(onlyoffice_pb2_grpc.OnlyOfficeConverterServicer):
    def ConvertPPTXToPDF(self, request, context):
        result = convert_with_onlyoffice(request.pptx_path)
        if result:
            return onlyoffice_pb2.ConvertResponse(pdf_path=result)
        return onlyoffice_pb2.ConvertResponse(pdf_path="", error="Conversion failed")

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=4))
    onlyoffice_pb2_grpc.add_OnlyOfficeConverterServicer_to_server(OnlyOfficeConverterServicer(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    print("OnlyOffice gRPC server running on port 50051...")
    server.wait_for_termination()
