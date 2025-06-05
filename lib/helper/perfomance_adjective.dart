String getAdjectiveForPerformance(int score) {
  if (score == 100) {
    return 'Perfect';
  } else if (score >= 90) {
    return 'Excellent';
  } else if (score >= 80) {
    return 'Great';
  } else if (score >= 70) {
    return 'Good';
  } else if (score >= 60) {
    return 'Fair';
  } else if (score >= 50) {
    return 'Developing';
  } else if (score >= 30) {
    return 'Needs Work';
  } else if (score > 0) {
    return 'Beginner';
  } else {
    return 'Unrated';
  }
}
