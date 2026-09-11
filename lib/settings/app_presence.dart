enum AppPresence {
  dockAndMenuBar('Dock and menu bar', 'Shows an icon in the Dock and another in the menu bar.'),
  dockOnly('Dock only', 'Shows an icon in the Dock. Cmd-Tab and the Dock tile both reach the app.'),
  menuBarOnly('Menu bar only', 'No Dock icon. The menu bar icon reaches settings and quit.'),
  hidden('Hidden', 'No Dock icon and no menu bar icon. Reopening from Applications or Spotlight opens settings.');

  final String title;
  final String explanation;

  const AppPresence(this.title, this.explanation);
}
