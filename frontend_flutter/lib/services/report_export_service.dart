import 'report_export_service_stub.dart'
    if (dart.library.html) 'report_export_service_web.dart' as impl;

class ReportExportService {
  Future<bool> exportTextFile({
    required String filename,
    required String content,
  }) {
    return impl.exportTextFileImpl(filename: filename, content: content);
  }
}
