String getCongratsForLanguage(String language) {
  switch (language.toLowerCase()) {
    case 'english':
      return 'Well done!';
    case 'spanish':
      return '¡Bien hecho!';
    case 'portuguese':
      return 'Parabéns!';
    case 'french':
      return 'Bravo !';
    case 'german':
      return 'Gut gemacht!';
    case 'italian':
      return 'Ben fatto!';
    case 'russian':
      return 'Молодец!';
    case 'chinese':
      return '干得好！'; // Gàn de hǎo!
    case 'japanese':
      return 'よくやった！'; // Yoku yatta!
    case 'korean':
      return '잘했어요!'; // Jalhaesseoyo!
    default:
      return 'Well done!';
  }
}
