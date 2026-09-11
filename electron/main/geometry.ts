import { Display, Rectangle } from 'electron';
import { NotchEdge } from '../../src/types';

export interface PanelSize {
  width: number;
  height: number;
}

export class NotchGeometry {
  /**
   * Calculates the exact window frame for the notch panel hugging the chosen edge
   * and centered along it, respecting the Dock and menu bar (workArea).
   */
  static calculatePanelFrame(display: Display, panelSize: PanelSize, edge: NotchEdge = 'right'): Rectangle {
    const full = display.bounds;
    const usable = display.workArea;

    const width = Math.ceil(panelSize.width);
    const height = Math.ceil(panelSize.height);

    let x = 0;
    let y = 0;

    switch (edge) {
      case 'right':
        x = Math.round(usable.x + usable.width - width);
        y = Math.round(full.y + (full.height - height) / 2);
        break;
      case 'left':
        x = Math.round(usable.x);
        y = Math.round(full.y + (full.height - height) / 2);
        break;
      case 'top':
        x = Math.round(full.x + (full.width - width) / 2);
        y = Math.round(usable.y);
        break;
      case 'bottom':
        x = Math.round(full.x + (full.width - width) / 2);
        y = Math.round(usable.y + usable.height - height);
        break;
    }

    return { x, y, width, height };
  }
}
