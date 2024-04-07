double caulateWidth(String content, maxWidth) {
  if (content.isEmpty) {
    return 0;
  }

  if (content.length < 5) {
    return 50;
  }

  if (content.length < 10) {
    return 75;
  }

  if (content.length < 20) {
    return 120;
  }

  if (content.length < 30) {
    return 160;
  }

  return maxWidth;
}
