// ==========================================================================
// Codenotch — JS Interop for Blazor
// Handles cursor tracking, animation helpers, and window interaction.
// ==========================================================================

window.NotchInterop = {

    // ---- Cursor tracking ----

    _cursorCallbackRef: null,
    _mouseMoveBound: null,

    /**
     * Start tracking the mouse cursor position globally within the webview.
     * Calls back to .NET with {x, y} on every mousemove.
     */
    startCursorTracking: function (dotnetRef) {
        this._cursorCallbackRef = dotnetRef;
        this._mouseMoveBound = (e) => {
            if (this._cursorCallbackRef) {
                this._cursorCallbackRef.invokeMethodAsync('OnCursorMoved', e.clientX, e.clientY);
            }
        };
        document.addEventListener('mousemove', this._mouseMoveBound, { passive: true });
    },

    stopCursorTracking: function () {
        if (this._mouseMoveBound) {
            document.removeEventListener('mousemove', this._mouseMoveBound);
            this._mouseMoveBound = null;
        }
        this._cursorCallbackRef = null;
    },

    // ---- Hit testing ----

    /**
     * Check if a point falls within any element matching the selector.
     */
    hitTest: function (x, y, selector) {
        const elements = document.querySelectorAll(selector);
        for (const el of elements) {
            const rect = el.getBoundingClientRect();
            if (x >= rect.left && x <= rect.right && y >= rect.top && y <= rect.bottom) {
                return true;
            }
        }
        return false;
    },

    /**
     * Get bounding rect of element by id.
     */
    getBoundingRect: function (elementId) {
        const el = document.getElementById(elementId);
        if (!el) return null;
        const rect = el.getBoundingClientRect();
        return { x: rect.x, y: rect.y, width: rect.width, height: rect.height };
    },

    // ---- Reduced motion ----

    /**
     * Check if the user prefers reduced motion.
     */
    prefersReducedMotion: function () {
        return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    },

    /**
     * Watch for reduced motion preference changes.
     */
    watchReducedMotion: function (dotnetRef) {
        const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
        mq.addEventListener('change', (e) => {
            dotnetRef.invokeMethodAsync('OnReducedMotionChanged', e.matches);
        });
    },

    // ---- SVG Path helpers ----

    /**
     * Generate the SVG path data for the notch shape.
     * Mirrors SideNotchShape.swift's canonicalPath() logic.
     *
     * @param {number} width - Total shape width (depth across)
     * @param {number} height - Total shape height (length along)
     * @param {number} cornerRadius - Corner radius for the body
     * @param {number} curlRadius - Flare radius at top/bottom
     * @param {number|null} hardwareNotchHeight - If joining hardware notch, its height
     * @param {string} edge - "right"|"left"|"top"|"bottom"
     */
    generateNotchPath: function (width, height, cornerRadius, curlRadius, hardwareNotchHeight, edge) {
        const isJoining = hardwareNotchHeight !== null && hardwareNotchHeight > 0;
        const bezelFillet = 4; // NotchLayout.bezelFillet
        const flare = isJoining ? bezelFillet : curlRadius;
        const cornerCap = isJoining ? hardwareNotchHeight / 2 : Infinity;

        // Clamping: corner first, flare takes what's left
        const wanted = Math.max(0, Math.min(cornerRadius, cornerCap, width / 2));
        const curl = Math.max(0, Math.min(flare, height / 2, width - wanted));
        const corner = Math.max(0, Math.min(wanted, (height - 2 * curl) / 2));

        const bodyTop = curl;
        const bodyBottom = height - curl;

        let d = '';
        // Start at screen edge, above the body
        d += `M ${width} 0`;

        // Top flare: arc from edge inward
        if (curl > 0) {
            d += ` A ${curl} ${curl} 0 0 1 ${width - curl} ${curl}`;
        }

        // Top body edge to top-left corner
        d += ` L ${corner} ${bodyTop}`;

        // Top-left corner arc (concave)
        d += ` A ${corner} ${corner} 0 0 0 0 ${bodyTop + corner}`;

        // Left side down
        d += ` L 0 ${bodyBottom - corner}`;

        // Bottom-left corner arc (concave)
        d += ` A ${corner} ${corner} 0 0 0 ${corner} ${bodyBottom}`;

        // Bottom body edge to bottom flare
        d += ` L ${width - curl} ${bodyBottom}`;

        // Bottom flare: arc back to edge
        if (curl > 0) {
            d += ` A ${curl} ${curl} 0 0 1 ${width} ${height}`;
        }

        d += ' Z';

        // Apply edge transform via CSS transform on the SVG container
        return d;
    },

    /**
     * Get CSS transform for the notch shape based on edge.
     */
    getNotchTransform: function (edge, depth) {
        switch (edge) {
            case 'right':
                return 'none';
            case 'left':
                return `scaleX(-1) translateX(-${depth}px)`;
            case 'top':
                // Quarter turn, bezel to top: swap x/y, flip y
                return `rotate(-90deg) translateX(-${depth}px)`;
            case 'bottom':
                return `rotate(90deg)`;
            default:
                return 'none';
        }
    },

    // ---- Tooltip tail ----

    /**
     * Generate SVG path for the tooltip tail triangle.
     * @param {string} direction - "leading"|"trailing"|"up"|"down"
     * @param {number} size - tail size
     */
    generateTailPath: function (direction, size) {
        const w = size;
        const h = size * 0.75;
        switch (direction) {
            case 'leading':  // points right
                return `M 0 0 L ${h} ${w/2} L 0 ${w} Z`;
            case 'trailing': // points left
                return `M ${h} 0 L 0 ${w/2} L ${h} ${w} Z`;
            case 'down':     // points up
                return `M 0 ${h} L ${w/2} 0 L ${w} ${h} Z`;
            case 'up':       // points down
                return `M 0 0 L ${w/2} ${h} L ${w} 0 Z`;
            default:
                return '';
        }
    },

    // ---- Context menu ----

    /**
     * Register right-click handler on the notch body.
     */
    registerContextMenu: function (dotnetRef) {
        document.addEventListener('contextmenu', (e) => {
            const notchBody = e.target.closest('.notch-body, .provider-cell, .settings-orb');
            if (notchBody) {
                e.preventDefault();
                dotnetRef.invokeMethodAsync('OnContextMenu', e.clientX, e.clientY);
            }
        });
    }
};
