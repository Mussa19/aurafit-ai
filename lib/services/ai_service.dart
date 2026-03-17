class AIService {

  Future<String> analyzeFood(String imagePath) async {

    await Future.delayed(
      const Duration(seconds: 2),
    );

    return "Chicken salad - 350 kcal";

  }

}