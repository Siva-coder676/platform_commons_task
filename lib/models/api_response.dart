
class ApiResponse<T> {
  final int page;
  final int totalPages;
  final int totalResults;
  final List<T> results;

  ApiResponse({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    List<T> resultsList = [];
    
    if (json.containsKey('data')) {
   
      resultsList = (json['data'] as List)
          .map((item) => fromJsonT(item))
          .toList();
      return ApiResponse(
        page: json['page'] ?? 1,
        totalPages: json['total_pages'] ?? 1,
        totalResults: json['total'] ?? resultsList.length,
        results: resultsList,
      );
    } else {
      
      resultsList = (json['results'] as List?)
          ?.map((item) => fromJsonT(item))
          .toList() ?? [];
      return ApiResponse(
        page: json['page'] ?? 1,
        totalPages: json['total_pages'] ?? 1,
        totalResults: json['total_results'] ?? resultsList.length,
        results: resultsList,
      );
    }
  }
}