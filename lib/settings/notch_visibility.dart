enum NotchVisibility {
  onHover('On hover', 'Folds into a small pill at rest; unfolds when the pointer reaches it.'),
  alwaysShow('Always show', 'Stays open at full size, showing all provider rings.'),
  hidden('Hide', 'Keeps the notch off screen entirely. Reopening the app opens settings.');

  final String title;
  final String explanation;

  const NotchVisibility(this.title, this.explanation);
}
