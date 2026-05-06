#!/usr/bin/env python3
"""
niri-dynamic-float.py
Floats windows that set their title/app-id after opening (e.g. Bitwarden on Zen).

Watches the niri IPC event stream and applies MoveWindowToFloating + optional
position/size when a window transitions into a matching state.

Based on YaLTeR's script from https://github.com/niri-wm/niri/discussions/1599
with the auto-restart wrapper from cc8dea2e's comment.
"""

from dataclasses import dataclass, field
import json
import logging
import os
import re
from socket import AF_UNIX, SHUT_WR, socket
import sys
from time import sleep

# ── Logging — goes to stdout so systemd journal picks it up ─────────────────
logging.basicConfig(
    stream=sys.stdout,
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)


# ── Match / Rule helpers (identical API to YaLTeR's original) ───────────────


@dataclass(kw_only=True)
class Match:
    """Match a window by title and/or app_id (both are Python regexes)."""

    title: str | None = None
    app_id: str | None = None

    def matches(self, window: dict) -> bool:
        if self.title is None and self.app_id is None:
            return False
        ok = True
        if self.title is not None:
            ok &= re.search(self.title, window["title"]) is not None
        if self.app_id is not None:
            ok &= re.search(self.app_id, window["app_id"]) is not None
        return ok


@dataclass
class Rule:
    """
    One rule = one window-rule {} block.
    A window must satisfy at least one `match` entry and none of the `exclude` entries.
    Optionally float to a fixed size / position.
    """

    match: list[Match] = field(default_factory=list)
    exclude: list[Match] = field(default_factory=list)
    # If set, resize the floating window to (width × height) logical pixels.
    width: float | None = None
    height: float | None = None
    # If set, move the window to (x, y) in global compositor coordinates.
    # For DP-3 (starts at x=1920, 2560×1440): x=3900, y=100 puts it top-right.
    x: float | None = None
    y: float | None = None

    def matches(self, window: dict) -> bool:
        if self.match and not any(m.matches(window) for m in self.match):
            return False
        if any(m.matches(window) for m in self.exclude):
            return False
        return True


# ── Rules ───────────────────────────────────────────────────────────────────
# Bitwarden extension popup in Zen Browser.
# Title: "Extension: (Bitwarden Password Manager) - Bitwarden — Zen Browser"
# app_id: "zen"
#
# Position: top-right of DP-3 (your main 2560×1440 monitor starting at x=1920).
# Adjust x/y to taste; set to None to skip repositioning.

RULES: list[Rule] = [
    Rule(
        match=[Match(title=r"Bitwarden", app_id=r"^zen$")],
        width=400.0,
        height=600.0,
        x=None,  # DP-3 right edge is at 1920+2560=4480; this sits ~100px from the right
        y=None,  # below the bar
    ),
]


# ── IPC helpers ─────────────────────────────────────────────────────────────


def _send(request: dict) -> None:
    with socket(AF_UNIX) as sock:
        sock.connect(os.environ["NIRI_SOCKET"])
        f = sock.makefile("rw")
        f.write(json.dumps(request))
        f.flush()


def _apply_rule(rule: Rule, win_id: int) -> None:
    """Float the window, then optionally resize and reposition it."""
    _send({"Action": {"MoveWindowToFloating": {"id": win_id}}})

    if rule.width is not None and rule.height is not None:
        _send(
            {
                "Action": {
                    "SetWindowWidth": {
                        "id": win_id,
                        "change": {"SetFixed": rule.width},
                    },
                }
            }
        )
        _send(
            {
                "Action": {
                    "SetWindowHeight": {
                        "id": win_id,
                        "change": {"SetFixed": rule.height},
                    },
                }
            }
        )

    if rule.x is not None and rule.y is not None:
        _send(
            {
                "Action": {
                    "MoveFloatingWindow": {
                        "id": win_id,
                        "x": {"SetFixed": rule.x},
                        "y": {"SetFixed": rule.y},
                    }
                }
            }
        )


def _update_matched(windows: dict, win: dict) -> None:
    win["matched"] = windows.get(win["id"], {}).get("matched", False)
    matched_before = win["matched"]

    matched_rule: Rule | None = next((r for r in RULES if r.matches(win)), None)
    win["matched"] = matched_rule is not None

    if win["matched"] and not matched_before:
        logger.info(
            "floating window  title=%r  app_id=%r  id=%s",
            win["title"],
            win["app_id"],
            win["id"],
        )
        _apply_rule(matched_rule, win["id"])  # type: ignore[arg-type]


# ── Main loop ────────────────────────────────────────────────────────────────


def main() -> None:
    if not RULES:
        logger.warning("RULES list is empty — nothing to do")
        sys.exit(0)

    sock = socket(AF_UNIX)
    sock.connect(os.environ["NIRI_SOCKET"])
    f = sock.makefile("rw")
    f.write('"EventStream"')
    f.flush()
    sock.shutdown(SHUT_WR)

    logger.info("listening for niri events …")
    windows: dict[int, dict] = {}

    for line in f:
        event = json.loads(line)

        if changed := event.get("WindowsChanged"):
            for win in changed["windows"]:
                _update_matched(windows, win)
            windows = {w["id"]: w for w in changed["windows"]}

        elif changed := event.get("WindowOpenedOrChanged"):
            win = changed["window"]
            _update_matched(windows, win)
            windows[win["id"]] = win

        elif closed := event.get("WindowClosed"):
            windows.pop(closed["id"], None)


if __name__ == "__main__":
    while True:
        try:
            main()
        except KeyboardInterrupt:
            logger.info("stopped by CTRL+C")
            break
        except Exception as exc:
            logger.error("crashed: %s — restarting in 5 s …", exc)
            sleep(5.0)
