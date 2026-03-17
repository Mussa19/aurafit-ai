class ApiService {

  Future<String> fetchNutrition(String food) async {

    await Future.delayed(
      const Duration(seconds: 2),
    );

    return "$food contains about 250 kcal";

  }

}